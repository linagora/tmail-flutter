# 0084. iOS Sentry dSYM & Dart Symbols Automation

Date: 2026-04-20

## Status

Accepted

## Context

iOS crash reports on Sentry are unreadable due to two levels of obfuscation:

1. **Native (Swift/Objective-C/C++):** Xcode strips debug symbols from the release binary — only raw memory addresses are shown instead of function names and line numbers.
2. **Dart:** ARM binaries lack debug info — only raw memory addresses are shown instead of Flutter stack traces.

This makes production crashes nearly impossible to debug.

## Decision

Update the iOS Fastlane build and CI/CD pipeline to automatically generate and upload de-obfuscation artifacts to Sentry on every release.

### Build (Fastlane — `ios/fastlane/Fastfile`)

Pass Flutter obfuscation build settings to `build_app` via `xcargs`. Flutter's `xcode_backend.sh` reads these Xcode build settings during the build phase:

```ruby
symbols_path = File.expand_path("../build/ios/outputs/symbols")
build_app(
  ...
  xcargs: "DART_OBFUSCATION=true SPLIT_DEBUG_INFO=#{symbols_path}",
  dsym_output_path: "../build/ios/outputs/dsym"
)
```

- `DART_OBFUSCATION=true` — instructs Flutter to obfuscate Dart code (value must be lowercase `true`, not `YES`).
- `SPLIT_DEBUG_INFO=<abs_path>` — strips Dart debug symbols from the binary into `build/ios/outputs/symbols/`.
- `dsym_output_path` — instructs Gym (Fastlane) to export the Xcode-generated dSYM to `build/ios/outputs/dsym/`.

### Pod dependency (`ios/Podfile`)

The `TwakeMailNSE` (Notification Service Extension) target must use `Sentry/HybridSDK` at the **exact same version** as `sentry_flutter` requires. Using plain `pod 'Sentry'` (Core subspec, pulls latest) causes a version conflict and `PrivateSentrySDKOnly not found` compile errors.

```ruby
target 'TwakeMailNSE' do
  use_frameworks!
  pod 'Sentry/HybridSDK', '8.56.2'  # must match sentry_flutter's requirement
end
```

### CI Pipeline (GitHub Actions — `.github/workflows/release.yaml`)

The two separate Sentry upload steps (iOS and Android) are merged into a single **"Upload Debug Symbols to Sentry"** step that runs on both matrix jobs independently. The step branches internally based on `${{ matrix.os }}`.

After a successful build, the step:

1. Validates that the git tag version matches the version in `pubspec.yaml`.
2. Creates a Sentry release.
3. For **iOS**:
   - Uploads `build/ios/outputs/dsym/` (dSYM — de-obfuscates native Swift/ObjC/C++ crashes).
   - Uploads `build/ios/outputs/symbols/` (Dart debug symbols — de-obfuscates Flutter stack traces).
4. For **Android**:
   - Uploads `build/app/outputs/mapping/release/mapping.txt` (ProGuard — de-obfuscates Java/Kotlin).
   - Uploads `build/app/outputs/symbols/` (Dart debug symbols).
5. Finalizes the release.

Independence between platforms is guaranteed by the matrix strategy (`fail-fast: false`) — iOS and Android run on separate runners, so a failure on one does not affect the other.

## Consequences

**Benefits:**
- Full readable stack traces for both Dart and native (Swift/ObjC/C++) crashes in Sentry.
- Automated — no manual upload step needed.
- Smaller app binary (debug info stripped from the IPA).
- Single unified Sentry upload step for both platforms — easier to maintain.

**Trade-offs:**
- Slightly longer CI build time (symbol separation + upload).
- `SENTRY_AUTH_TOKEN`, `SENTRY_ORG`, `SENTRY_PROJECT` must be maintained as CI secrets.
- `pod 'Sentry/HybridSDK'` version in `Podfile` must be kept in sync manually when upgrading `sentry_flutter`.
- Symbol files must be uploaded in the **same workflow run** as the build — running `flutter clean` between build and upload will break de-obfuscation.
