# 0073 - Android Auto Backup & Session Restore

Date: 2026-03-31

## Status

Accepted

## Context

Android 6.0+ (API 23+) enables Auto Backup by default. App data is automatically backed up to the user's private Google Drive folder (up to 25 MB per app) and **restored before the app first launches** after reinstall.

**The problem:** Hive databases and `SharedPreferences` restored from backup cause the app to auto-login with stale credentials without re-authentication.

The fix must handle all cases correctly:

**Old user** (prior version had backup enabled):

| # | Scenario | Required Behavior |
|---|---|---|
| 1 | Update old version → new version | Keep auto login |
| 2 | Uninstall → reinstall new version | Force login |

**New user** (installs new version directly):

| # | Scenario | Required Behavior |
|---|---|---|
| 3 | Fresh install | Force login |
| 4 | Uninstall → reinstall | Force login |

## Decision

**Disable Android Auto Backup** by:

1. Setting `android:allowBackup="false"` — disables cloud backup on all Android versions.
2. Adding `android:dataExtractionRules` (Android 12+ / API 31+) with empty `<cloud-backup>` and `<device-transfer>` blocks — because `allowBackup=false` alone does **not** block device-to-device (D2D) transfers on Android 12+. An empty block means no data is included, so no explicit `<exclude>` rules are needed.

> `fullBackupContent` (Android ≤ 11) is not required here — it only applies when backup is enabled. Since `allowBackup=false` already disables cloud backup on those versions, there is nothing to configure.

**`AndroidManifest.xml`:**
```xml
<application
    android:allowBackup="false"
    android:dataExtractionRules="@xml/data_extraction_rules"
    ...>
```

**`res/xml/data_extraction_rules.xml`** (Android 12+):
```xml
<?xml version="1.0" encoding="utf-8"?>
<data-extraction-rules>
    <cloud-backup/>
    <device-transfer/>
</data-extraction-rules>
```

## Consequences

### Positive
- **No logout regression on update** — app data stays on device through updates; no startup detection logic required.
- No backend changes required — fully client-side.
- Covers both cloud backup and D2D transfers across all Android versions (6.0+).
- Minimal config: one XML file + one manifest attribute. No verbose exclude rules needed.

### Negative / Trade-offs
- User still be auto login in case of **Backup → uninstall → reinstall new version**
- `allowBackup=false` alone is insufficient on Android 12+ — a `dataExtractionRules` file with empty `<device-transfer>` is mandatory to also block D2D transfers.

**Scenario matrix post-decision:**

**Old user** — previously installed a version with `allowBackup=true` (backup was created):

| # | Scenario | Behavior |
|---|---|---|
| 1 | Update old version → new version | Data stays on device, no logout |
| 2 | Uninstall → reinstall new version | Old backup still restored, auto login |

**New user** — installed new version directly (no prior backup ever created):

| # | Scenario | Behavior |
|---|---|---|
| 3 | Fresh install | No data, force login |
| 4 | Uninstall → reinstall | No backup to restore, force login |

## Alternatives

### Option 2 — Disable backup + Secure Storage sentinel token
Store a sentinel token in `flutter_secure_storage` (Android Keystore — hardware-bound, never exported in backups). On startup: Hive data present + sentinel absent → data is from a backup → force login.

| Case | Result |
|---|---|
| Update (Case 1) | ❌ Logged out (no sentinel in old install) |
| Uninstall + reinstall (Case 2) | ✅ Force login (Keystore cleared on uninstall) |
| Fresh install (Case 3) | ✅ Force login |

**Why not chosen:** Same Case 1 regression as the chosen option, with added complexity. Requires a `flutter_secure_storage` dependency, an extra Keystore read on every cold start, and additional failure surface (Keystore unavailable on some low-end devices). No improvement for the affected case.

### Option 3 — File timestamp heuristic
Compare Hive database file timestamps against `PackageInfo.firstInstallTime` to infer whether files were restored from backup.

| Case | Result |
|---|---|
| Update (Case 1) | ⚠️ Unreliable |
| Uninstall + reinstall (Case 2) | ⚠️ Unreliable |
| Fresh install (Case 3) | ⚠️ Unreliable |

**Why not chosen:** Android Auto Backup can preserve original file timestamps on restore. Behavior varies by OEM and Android version — `firstInstallTime` reflects the current install but restored files may carry timestamps from the previous install, which is indistinguishable from a normal update. Not deterministically testable.

### Option 4 — Backend session validation
Validate the local session token server-side on every cold start. The server invalidates tokens from a previous install upon re-login; the next reinstall then correctly rejects the stale token.

| Case | Result |
|---|---|
| Update (Case 1) | ✅ Keep auto login |
| Uninstall + reinstall (Case 2) | ✅ Force login (from 2nd reinstall onward) |
| Fresh install (Case 3) | ✅ Force login |

**Why not chosen:** Requires backend API changes, adds startup latency on every cold start, and introduces an offline failure mode: if there is no network on startup the app must decide whether to trust the local session or block login — either choice creates a security/UX trade-off. The only complete solution for Case 1, but out of scope for the current release cycle.

## References

- [Android Auto Backup](https://developer.android.com/identity/data/autobackup)
- [Data extraction rules — Android 12+](https://developer.android.com/identity/data/autobackup#xml-syntax-android-12)
- [flutter\_secure\_storage](https://pub.dev/packages/flutter_secure_storage)
- [Android Keystore System](https://developer.android.com/privacy-and-security/keystore)
