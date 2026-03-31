# 0073 - Android Auto Backup & Session Restore

Date: 2026-03-31

## Status

Proposed

## Context

Android 6.0+ enables Auto Backup by default, backing up Hive databases and SharedPreferences to Google Drive. On reinstall, this data is restored **before the app first launches** — causing the app to auto-login without re-authentication.

The fix must handle three cases correctly:

| # | Scenario | Required Behavior |
|---|---|---|
| 1 | Update from old → new version | ✅ Keep auto login (hard requirement) |
| 2 | Backup → uninstall → reinstall new version | ❌ Force login |
| 3 | Fresh install | ❌ Force login |

**Core challenge:** Cases 1 and 2 are **technically identical on the client** — both have Hive data present and Secure Storage empty. No client-side signal can reliably distinguish them.

## Options Considered

| Option | Case 1 (update) | Case 2 (uninstall+backup) | Case 3 (fresh) | Backend? |
|---|---|---|---|---|
| 1. Disable backup only | ❌ Logged out | ❌ Still broken | ✅ | No |
| 2. Disable backup + Secure Storage token | ❌ Logged out | ✅ | ✅ | No |
| 3. File timestamp heuristic | ⚠️ Unreliable | ⚠️ Unreliable | ⚠️ | No |
| 4. Backend session validation | ✅ | ✅ (2nd time+) | ✅ | **Yes** |

**Option 2** stores the auth token in `flutter_secure_storage` (Android Keystore, never backed up). Uninstall clears it → force login. But users updating from old version have no token yet → also logged out, violating Case 1.

**Option 4** validates the session token server-side on each startup. The server invalidates old tokens on re-login, making Case 2 correct on the second reinstall. Only complete solution but requires backend changes and adds startup latency.

> Note: On Android 12+, `allowBackup=false` only disables cloud backup. `dataExtractionRules` is required to also block device-to-device (D2D) transfers.

## Open Questions

- Can the team accept Option 2's trade-off — users updating from the old version are logged out **exactly once**? If yes → Option 2 is the simplest path.
- Can the backend support session validation? If yes → Option 4 is the only complete solution.
- If Option 4: how to handle offline startup (trust local session when no network)?

## Decision

Pending team discussion. No decision made yet.

## References

- [Android Auto Backup](https://developer.android.com/identity/data/autobackup)
- [flutter\_secure\_storage](https://pub.dev/packages/flutter_secure_storage)
- [Android Keystore System](https://developer.android.com/privacy-and-security/keystore)
