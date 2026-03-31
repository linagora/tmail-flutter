# 0073 - Android Auto Backup & Session Restore

Date: 2026-03-31

## Status

Proposed

## Context

### Background: Android Auto Backup

Starting from Android 6.0 Marshmallow, the `allowBackup` flag is enabled by default (`true`), allowing the system to automatically back up app data including SharedPreferences, databases, and internal files to the user's Google Drive. When reinstalling the app or setting up a new device, the system automatically restores this data **before the app is launched for the first time**.

| Question | Answer |
|---|---|
| What is it? | Android's automatic backup mechanism that uploads SharedPreferences, databases, and files to Google Drive when the device is idle, charging, and connected to Wi-Fi. |
| Why was it added? | To reduce friction when users switch devices or reinstall apps — preserving app state, keeping users logged in, and avoiding data loss. |
| Is it common practice? | Yes. Auto Backup is enabled by default and widely used. However, apps handling sensitive data (auth tokens, encryption keys) often disable it or exclude specific data for security reasons. |
| Does disabling it bring trade-offs? | Yes. Better security and avoids key mismatch issues, but users will lose local data on reinstall or device change and must log in again. |

### Current Problem

The app currently does not set the `allowBackup` flag in `AndroidManifest.xml`. Android enables Auto Backup by default, causing all Hive database and SharedPreferences data to be backed up to Google Drive.

When a user backs up their data, uninstalls the app, and reinstalls it, Android restores this data before the app runs for the first time. Since account information remains in Hive, the app reads the old session and **automatically logs in without requiring re-authentication**.

### Three Cases to Handle After the Fix

| # | Scenario | Current Behavior | Expected After Fix |
|---|---|---|---|
| 1 | Currently using old version → update to new version | ✅ Auto login | ✅ Must continue to auto login (**hard requirement**) |
| 2 | Backed up data, uninstalled → reinstall new fixed version | ❌ Auto login (bug) | ✅ Must require login |
| 3 | Fresh install (never used the app before) | ✅ Requires login | ✅ Must require login |

## Problem Analysis

### The Core Challenge

The challenge is not just disabling backup — it's **distinguishing between two states** after the fix, because both produce identical technical results on the device:

| State | Hive | Secure Storage | Requirement |
|---|---|---|---|
| Update app from old to new version | ✅ Has data | ❌ Empty (never written) | ✅ Allow auto login |
| Uninstall (with backup) → reinstall new version | ✅ Has data (restored) | ❌ Empty (cleared on uninstall) | ❌ Force login |

**These two cases are technically identical on the client side.** There is no information on the device that can reliably distinguish them without server support.

## Options Considered

### Option 1: Disable Auto Backup (`allowBackup=false`)

Set `allowBackup=false` in `AndroidManifest.xml` combined with `dataExtractionRules` to exclude all Hive and SharedPreferences data from backup.

**Pros:** Simple, no additional logic required. Prevents backup from the new version onwards.

**Cons:** Does not solve the Case 1 vs Case 2 distinction problem. Users updating from the old version will still be logged out because there is no mechanism to differentiate an update from a restore.

| # | Case | Before Fix | After Fix | Requirement |
|---|---|---|---|---|
| 1 | Update app | ✅ Auto login | ❌ Logged out | Hard requirement |
| 2 | Uninstall + reinstall (with backup) | ❌ Auto login (bug) | ❌ Still auto login (old backup persists) | Must fix |
| 3 | Fresh install | ✅ Force login | ✅ Force login | Already correct |

> **Note:** On Android 12+, `allowBackup=false` only disables cloud backup (Google Drive) but **does not** disable device-to-device (D2D) transfers. `dataExtractionRules` is required to control D2D behavior.

### Option 2: Disable Auto Backup + Flutter Secure Storage

Combines Option 1 with moving the auth token to `flutter_secure_storage` (backed by Android Keystore — never included in any backup). On app startup, check Secure Storage: token present → auto login, token absent → force login.

**Pros:** Correctly handles Case 2 and Case 3. Secure Storage is never backed up — when the app is uninstalled the token is cleared, so reinstalling requires login.

**Cons:** Still cannot distinguish Case 1 from Case 2. Both produce the same result: Secure Storage empty + Hive has data. Users updating from the old version (who have never written a token to Secure Storage) will be logged out — **violating the hard requirement**.

| # | Case | Secure Storage | Result | Requirement |
|---|---|---|---|---|
| 1 | Update from old version | ❌ Empty (never written) | ❌ Logged out | Hard requirement |
| 2 | Uninstall + reinstall (with backup) | ❌ Empty (cleared) | ❌ Force login | ✅ Correct |
| 3 | Fresh install | ❌ Not present | ❌ Force login | ✅ Correct |

### Option 3: File Timestamp Detection

Based on the hypothesis that when Android restores a backup, the `.hive` file is written fresh → the creation timestamp would reflect the restore time, which differs from a user who has been continuously using the app.

**Pros:** No backend required. If it works, could potentially distinguish update from restore.

**Cons / Reason for rejection:** No official Google documentation confirms timestamp behavior during backup restore. Behavior depends on Android version, filesystem (FUSE vs SDCardFS), and OEM implementation. Not reliable enough to use as a security gate.

### Option 4: Backend Session Validation

On successful login, the server issues and stores a session token. Each time the app starts, it calls an API to validate the token. When the user logs in again (after uninstall + reinstall), the server issues a new token and invalidates the old one.

**Pros:** The only solution that correctly handles all 3 cases. The server is the source of truth — independent of client state.

**Cons:** Requires backend API changes. Adds latency on app startup (requires a network call).

| # | Case | Server Token | Result | Requirement |
|---|---|---|---|---|
| 1 | Update app | ✅ Still valid | ✅ Auto login | ✅ Correct |
| 2 | Uninstall + reinstall (with backup, 1st time) | ✅ Still valid (not yet re-logged in) | ✅ Auto login | Acceptable |
| 2b | Uninstall + reinstall (with backup, 2nd time+) | ❌ Invalidated | ❌ Force login | ✅ Correct |
| 3 | Fresh install | ❌ Not present | ❌ Force login | ✅ Correct |

## Options Summary

| Option | Case 1 (update) | Case 2 (uninstall+backup) | Case 3 (fresh install) | Needs Backend? |
|---|---|---|---|---|
| Option 1: Disable Backup only | ❌ Logged out | ❌ Still broken | ✅ | No |
| Option 2: Disable Backup + Secure Storage | ❌ Logged out | ✅ | ✅ | No |
| Option 3: File timestamp | ⚠️ Unreliable | ⚠️ Unreliable | ⚠️ | No |
| Option 4: Backend validation | ✅ | ✅ (2nd time+) | ✅ | **Yes** |

**No client-only solution can correctly handle both Case 1 (hard requirement) and Case 2 simultaneously.** This is a technical limitation: after a backup restore, the device leaves no reliable signal that the app can use to determine whether data came from an update or a restore.

## Open Questions

- Is the team willing to accept the trade-off in Option 2 — users updating from the old version are logged out **exactly once** when upgrading? If this hard requirement can be relaxed → Option 2 is the simplest viable solution.
- Can the backend be extended to support session validation? If yes → Option 4 is the only complete solution.
- If Option 4 is chosen, how should offline behavior be handled (trust local session when there is no network)?

## Decision

No decision has been made. This ADR is in **Proposed** status, pending team discussion and trade-off evaluation across the options above.

## References

- [Android Developers — Back up user data with Auto Backup](https://developer.android.com/identity/data/autobackup)
- [Google One Help — Backup retention policy (57-day device inactivity)](https://support.google.com/googleone/answer/9149304)
- [Android Developers — Data backup overview](https://developer.android.com/identity/data/backup)
- [flutter\_secure\_storage package](https://pub.dev/packages/flutter_secure_storage)
- [Android Keystore System](https://developer.android.com/privacy-and-security/keystore)
