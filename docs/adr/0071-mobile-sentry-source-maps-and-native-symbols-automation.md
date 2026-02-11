# 71. Mobile Sentry Source Maps & Native Symbols Automation

Date: 2026-02-11

## Status

Accepted

## Context

The `tmail-flutter` application utilizes Sentry for error monitoring. While the Web platform successfully uploads source maps for readable stack traces, the Mobile platforms (Android & iOS) currently lack this capability.

Mobile crash reports on Sentry are currently unreadable due to platform-specific obfuscation:

1. **Android (Java/Kotlin):** Native code is minified and obfuscated by R8/ProGuard (e.g., classes appear as `a.b.c`).
2. **iOS (Obj-C/Swift):** Native crash reports contain raw memory addresses (hexadecimal) instead of symbols, requiring **dSYM** files to resolve.
3. **Flutter (Dart - Both Platforms):** The compiled Dart native code (ARM64) lacks debug information, displaying raw memory addresses instead of file names and line numbers.

This limitation makes debugging production crashes—whether they are `NullPointerExceptions` on Android, `EXC_BAD_ACCESS` on iOS, or logic errors deep within Dart code—nearly impossible.

There is a requirement to automate the upload of **ProGuard Mapping** (Android), **dSYMs** (iOS), and **Dart Debug Symbols** (Both) to Sentry within the CI/CD pipeline for every release.

## Decision

We have decided to update the Android and iOS Build/Release workflows to support comprehensive de-obfuscation on Sentry.

### 1. Build Configuration (Fastlane)

We updated the `Fastfile` for both platforms to enforce code obfuscation and the separation of debug information.

#### Android

We modified the build command to use `--obfuscate` and `--split-debug-info`.

| Parameter | Value | Purpose |
| --- | --- | --- |
| `--obfuscate` | `true` | Minifies code to reduce size and obfuscate logic. |
| `--split-debug-info` | `../build/app/outputs/symbols` | Extracts debug info into a separate directory. |

#### iOS (Hybrid Strategy)

We adopted a **Hybrid Build Strategy** because the standard Fastlane `build_app` (gym) action does not natively support Flutter's obfuscation flags.

1. **Compile & Archive:** We use `flutter build ipa` directly via shell to compile code with obfuscation flags and generate an `.xcarchive`.
2. **Export:** We use Fastlane's `build_app` only to sign and export the pre-built archive into an `.ipa`.

**iOS Command (Fastfile):**

```ruby
# Step 1: Compile with obfuscation and symbols
sh "flutter", "build", "ipa", "--release", "--obfuscate", "--split-debug-info=../build/ios/outputs/symbols", "--export-method=app-store"

# Step 2: Export IPA using Fastlane Gym
build_app(..., skip_build_archive: true, archive_path: "../build/ios/archive/Runner.xcarchive")

```

### 2. CI Pipeline Strategy (GitHub Actions)

The GitHub Actions `release.yaml` workflow has been expanded to include a unified **Sentry Artifact Upload** step immediately following a successful build.

The process flow is as follows:

1. **Build App:** Fastlane generates the binaries (`.aab`/`.ipa`) and the debug artifacts (`mapping.txt`, `dSYMs`, `symbols/`).
2. **Create Release:** A Sentry release is created, matching the version defined in `pubspec.yaml`.
3. **Upload Native Artifacts:**
* **Android:** Uploads `mapping.txt` (ProGuard).
* **iOS:** Finds and uploads `Runner.app.dSYM` located inside the `.xcarchive`.


4. **Upload Dart Artifacts:** The `.symbols` directories for both platforms are scanned and uploaded to de-obfuscate Flutter crashes.
5. **Finalize:** The release is marked as final.

### 3. Artifact Locations

We standardized the artifact output locations in the CI environment:

| Platform | Artifact Type | Path | Purpose |
| --- | --- | --- | --- |
| **Android** | ProGuard Mapping | `build/app/outputs/mapping/release/mapping.txt` | De-obfuscate Java/Kotlin |
| **Android** | Dart Symbols | `build/app/outputs/symbols` | De-obfuscate Flutter (Android) |
| **iOS** | Native dSYM | `build/ios/archive/Runner.xcarchive/dSYMs` | De-obfuscate Obj-C/Swift |
| **iOS** | Dart Symbols | `build/ios/outputs/symbols` | De-obfuscate Flutter (iOS) |

## Consequences

### Benefits

* **Full Stacktrace Visibility:** Sentry will accurately display filenames, function names, and line numbers for Dart, Java/Kotlin, and Swift/Obj-C crashes.
* **Automated Workflow:** Eliminates manual upload steps, preventing "missing dSYM" errors common in iOS releases.
* **Optimized App Size:** Using `--split-debug-info` reduces the final download size of the application for users on both platforms.
* **Platform Parity:** Ensures debugging capabilities are consistent across Web, Android, and iOS.

### Trade-offs

* **Build Time:** Release build times increase slightly due to symbol separation and network upload time.
* **Fastlane Complexity (iOS):** The iOS Fastfile is more complex due to the split between "Build Archive" and "Export IPA" steps.
* **CI Configuration:** Requires careful management of pathing (`working-directory`) in GitHub Actions to distinguish between Android and iOS build artifacts.

## Developer Guidelines

### Verification

To verify a successful upload:

1. Navigate to Sentry Project > **Releases**.
2. Select the recently built version.
3. Check the **Artifacts** tab. You should see:
* **Android:** `mapping.txt` (Type: *ProGuard*).
* **iOS:** Files ending in `.dSYM` (Type: *Debug Information*).
* **Both:** Files ending in `.symbols` (Type: *Debug Information*).



### Troubleshooting

* **iOS "Missing dSYM":** If Sentry says dSYMs are missing, ensure `Bitcode` is disabled in Xcode (standard for Flutter). Also, verify the CI script is looking inside the `.xcarchive`.
* **"No such file or directory":** Ensure no `flutter clean` commands run between the **Build** and **Upload** steps.
* **Sentry Auth:** Verify `SENTRY_AUTH_TOKEN`, `SENTRY_ORG`, and `SENTRY_PROJECT` secrets are active.