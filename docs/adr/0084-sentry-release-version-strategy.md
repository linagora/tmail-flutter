# 0084. Sentry Release Version Strategy (Mobile)

Date: 2026-04-22

## Status

Accepted

## Context

> **Scope: iOS and Android mobile only.** Web uses a separate Sentry project and version injection mechanism.

Sentry requires the release version reported by the app to exactly match the release version used when uploading debug symbols (dSYMs / source maps). A mismatch breaks symbolication — crash stack traces become unreadable.

There are three version sources that must stay in sync:

1. **Git tag** — Fastlane reads this via `last_git_tag` and injects it as `SENTRY_RELEASE` into the app via `dart-define` (base64-encoded `DART_DEFINES`)
2. **`pubspec.yaml` version** — used by CI only for base-version validation; **not** used as `SENTRY_RELEASE`
3. **`CFBundleShortVersionString` (iOS)** — derived from pubspec; Apple requires `X.Y.Z` format only — no `-rc` suffix allowed

The challenge: RC builds use a `-rcXX` suffix in the tag (e.g. `v0.28.5-rc01`), but Apple rejects that suffix in `CFBundleShortVersionString`.

## Decision

**Rule: pubspec version = git tag base version (no `-rc` suffix). The full tag is used as `SENTRY_RELEASE`.**

| Source | RC build example | Final release example |
|---|---|---|
| Git tag | `v0.28.5-rc01` | `v0.28.5` |
| pubspec version | `0.28.5` | `0.28.5` |
| App Store / CFBundleShortVersionString | `0.28.5` ✅ | `0.28.5` ✅ |
| SENTRY_RELEASE (app + CI) | `0.28.5` | `0.28.5` |

### What breaks if you deviate

| Mistake | Result |
|---|---|
| pubspec = `0.28.5-rc01`, tag = `v0.28.5-rc01` | Apple rejects the iOS build (`CFBundleShortVersionString` must be `X.Y.Z`) |
| pubspec = `0.28.5-rc01`, tag = `v0.28.5` | Validation passes but app reports `"0.28.5"`, CI uploads to `"0.28.5-rc01"` → mismatch |

## Consequences

- pubspec always stays App Store-safe (`X.Y.Z`, no suffix)
- RC distinction lives only in the git tag
- CI validates base version consistency; pubspec version drives `SENTRY_RELEASE`
