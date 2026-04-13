# 0076. Android Sentry Source Maps & Native Symbols Automation

Date: 2026-02-11

## Status

Accepted

## Context

Android crash reports on Sentry are unreadable due to two levels of obfuscation:

1. **Java/Kotlin:** Minified by R8/ProGuard (e.g., classes appear as `a.b.c`).
2. **Dart:** ARM binaries lack debug info — only raw memory addresses are shown.

This makes production crashes nearly impossible to debug.

## Decision

Update the Android CI/CD pipeline to automatically upload de-obfuscation artifacts to Sentry on every release.

### Build (Fastlane)

Add `--obfuscate --split-debug-info=build/app/outputs/symbols` to the Flutter build command (executed from repository root after `cd ..`). This strips debug info from the binary into a separate `symbols/` directory.

### CI Pipeline (GitHub Actions)

After a successful build, the `release.yaml` workflow:

1. Creates a Sentry release matching the version in `pubspec.yaml`.
2. Uploads `build/app/outputs/mapping/release/mapping.txt` (ProGuard — de-obfuscates Java/Kotlin).
3. Uploads `build/app/outputs/symbols/` (Dart debug symbols — de-obfuscates Flutter stack traces).
4. Finalizes the release.

## Consequences

**Benefits:**
- Full readable stack traces for both Dart and Java/Kotlin crashes in Sentry.
- Automated — no manual upload step needed.
- Smaller app binary (debug info stripped from the APK/AAB).

**Trade-offs:**
- Slightly longer CI build time (symbol separation + upload).
- `SENTRY_AUTH_TOKEN`, `SENTRY_ORG`, `SENTRY_PROJECT` must be maintained as CI secrets.
- Symbol files must be uploaded in the **same workflow run** as the build — running `flutter clean` between build and upload will break de-obfuscation.
