# 71. Android Sentry Source Maps & Native Symbols Automation

Date: 2026-02-11

## Status

Accepted

## Context

The `tmail-flutter` application utilizes Sentry for error monitoring. While the Web platform successfully uploads source maps for readable stack traces, the Android platform currently lacks this capability.

Android crash reports on Sentry are currently unreadable due to two levels of obfuscation:

1. **Java/Kotlin Obfuscation:** The Android native code is minified and obfuscated by R8/ProGuard during the release build (e.g., classes appear as `a.b.c`).
2. **Dart Obfuscation:** The compiled Dart native code (ARM64/ARM) lacks debug information, displaying raw memory addresses instead of file names and line numbers.

This limitation makes debugging production crashes—especially `NullPointerExceptions` in native layers or logic errors deep within Dart code—nearly impossible.

There is a requirement to automate the upload of both **ProGuard Mapping** and **Dart Debug Symbols** to Sentry within the CI/CD pipeline for every release.

## Decision

We have decided to update the Android Build and Release workflow to support comprehensive de-obfuscation on Sentry.

### 1. Build Configuration (Fastlane)

We updated the `Fastfile` to modify the Flutter build command. Instead of a standard release build, we now enforce code obfuscation and the separation of debug information.

| Parameter | Value | Purpose |
| --- | --- | --- |
| `--obfuscate` | `true` | Minifies code to reduce size and obfuscate logic (Standard practice). |
| `--split-debug-info` | `../build/app/outputs/symbols` | **New Decision:** Extracts debug information from the app binary into a separate directory. These files map binary instructions back to Dart source code. |

**Command:**

```ruby
sh "flutter build appbundle --release --obfuscate --split-debug-info=../build/app/outputs/symbols ..."

```

### 2. CI Pipeline Strategy (GitHub Actions)

The GitHub Actions `release.yaml` workflow has been expanded to include specific Sentry artifact upload steps immediately following a successful build.

The process flow is as follows:

1. **Build App:** Fastlane generates the `.aab`, the `mapping.txt` file, and the `symbols` directory.
2. **Create Release:** A Sentry release is created, matching the version defined in `pubspec.yaml`.
3. **Upload ProGuard:** The `mapping.txt` is uploaded to de-obfuscate Java/Kotlin stack traces (Android System crashes).
4. **Upload Debug Files:** The `.symbols` directory is scanned and uploaded to de-obfuscate Dart stack traces (Flutter crashes).
5. **Finalize:** The release is marked as final.

### 3. Artifact Locations

We standardized the artifact output locations in the CI environment to ensure the upload script can locate them reliably:

* **ProGuard Mapping:** `build/app/outputs/mapping/release/mapping.txt` (Gradle/Flutter default).
* **Dart Symbols:** `build/app/outputs/symbols` (Defined by the `--split-debug-info` flag).

## Consequences

### Benefits

* **Full Stacktrace Visibility:** Sentry will accurately display filenames, function names, and line numbers for both Dart and Java/Kotlin crashes.
* **Automated Workflow:** Removes the need for manual uploads by developers, preventing human error or missing mapping files for releases.
* **Optimized App Size:** Using `--split-debug-info` reduces the final download size of the application for users, as debug data is stripped from the binary.
* **Web Parity:** Brings Mobile debugging capabilities up to par with the existing Web implementation.

### Trade-offs

* **Build Time:** Release build times will increase slightly due to the symbol separation process and the network time required to upload artifacts.
* **CI Complexity:** The YAML configuration and Fastfile are more complex, requiring maintenance of environment variables (`SENTRY_AUTH_TOKEN`, `SENTRY_ORG`, etc.).
* **Storage:** Temporary storage is required on the CI runner for symbol files (though these are cleaned up after the job).

## Developer Guidelines

### Verification

To verify a successful upload:

1. Navigate to Sentry Project > **Releases**.
2. Select the recently built version (e.g., `1.0.0+1`).
3. Check the **Artifacts** tab.
* You must see a `mapping.txt` file (Type: *ProGuard*).
* You must see files ending in `.symbols` (Type: *Debug Information*, e.g., `app.android-arm64.symbols`).



### Troubleshooting

* **"No such file or directory":** Ensure that no `flutter clean` commands are executed between the **Build** step and the **Upload** step in the CI pipeline.
* **Sentry Auth Errors:** Verify that `SENTRY_AUTH_TOKEN` is correctly set in GitHub Secrets and that `SENTRY_ORG`/`SENTRY_PROJECT` environment variables are correct.
* **"Missing debug image":** If Sentry reports a missing debug image for a specific crash, the uploaded symbols do not match the binary on the user's device. Ensure the upload happens in the exact same workflow run as the build.