# 73. Prevent notification storm on Android

Date: 2026-03-13

## Status

Proposed

# Context

Some Android users reported a **notification storm** when reopening their mobile device after a long idle period (for example overnight).

When the device reconnects to the network, the server may send a large number of push notifications in a very short time.

Example scenario:

```text
100 push events at T0
100 push events at T0 + 31 seconds
```

This results in:

* Hundreds of **local notifications**
* Android notification service overload
* Device freezing for several minutes

## How Android push notifications work

FCM (Firebase Cloud Messaging) delivers push events to the app via a background handler (`handleFirebaseBackgroundMessage`).

The FCM background handler runs inside a short-lived Flutter isolate.

Background handlers are designed to execute quickly and may be terminated by the Android system at any time after the push event is delivered.

Because of this limitation, long-running operations such as delaying processing for an aggregation window (for example waiting 1 minute before generating notifications) are not reliable.

If the isolate is terminated before the delay completes, notifications may never be generated.

## collapse_key

FCM supports a `collapse_key` field that instructs the platform to deliver only the most recent message of a given key when multiple messages have been queued while the device was offline.

This is a server-side mechanism that the backend team configures when sending push events. If `collapse_key` is applied, the device receives a single push event instead of a burst, which prevents the storm at the source.

The measures described in this ADR are **complementary** to `collapse_key`: they protect the client in cases where burst delivery still occurs (e.g. `collapse_key` not yet deployed, or multiple collapse groups arriving at once).

See the backend issue for details on how `collapse_key` is configured server-side (Reference section).

# Root Causes

## 1. Each FCM event triggers the full notification pipeline

Current flow:

```text
FCM message
   ↓
handleFirebaseBackgroundMessage
   ↓
FcmMessageController
   ↓
EmailChangeListener
   ↓
LocalNotificationManager.showPushNotification()
```

Each email generates **one notification**.

When many pushes arrive simultaneously, the application generates **hundreds of notifications**.

## 2. Notification grouping happens too late

`groupPushNotificationOnAndroid()` is executed **after notifications are already created**.

Grouping therefore does **not reduce the number of notifications generated**, it only affects how they are displayed.

## 3. Push bursts during device reconnection

When the device reconnects to the network, the push system may deliver many push events within a short time window.

Without protection, every push event is processed independently, which repeatedly triggers the notification pipeline.

## 4. Local notification removal occasionally fails

Sentry reports the following error:

```text
PlatformException: Missing type parameter
FlutterLocalNotificationsPlugin.removeNotificationFromCache
```

This error prevents some notifications from being removed correctly from the notification cache.

When notification removal fails:

* stale notifications remain active
* notification grouping becomes inconsistent
* the total number of active notifications increases

# Decision

The measures below complement the server-side `collapse_key` mechanism. Given the scope of work, items are prioritised using MoSCoW to guide sprint planning.

| Item | Priority | Comment |
|------|----------|---------|
| Skip notifications when in foreground | **MUST** | |
| Limit number of notifications | **MUST** | |
| Fix local notification removal error | **SHOULD** | |
| Heuristic for important push (`needs-action` + INBOX) | **SHOULD** | Needs product validation |
| Separate subscription for `resync` and `notifs` | **WON'T** | Correlated with app removal — tracked separately |
| Debounce on app side | **WON'T** | Other steps make this an edge case not worth the team time to fix |

## 1. Skip notifications when in foreground

When the user is actively using the app, local push notifications should **not** be displayed — the user can see new emails directly in the UI.

The delivery state must still be updated when the email state cache is refreshed during foreground synchronization, to ensure state consistency for the next background wake.

Example integration:

```dart
await stateCacheManager.saveState(
  accountId,
  userName,
  StateCache(StateType.email, newState),
);

await FCMCacheManager.storeStateToRefresh(
  accountId,
  userName,
  TypeName.emailDelivery,
  newState,
);
```

## 2. Limit number of notifications

When a push burst is processed, the system limits the number of generated notifications.

Rules:

* maximum **20 notifications**
* prioritise emails requiring user action
* regular emails generate notifications **only if they belong to the Inbox mailbox**
* remaining emails sorted by newest first

Example scenario:

```text
200 emails arrive in a burst
```

Result:

```text
Only 20 notifications are generated
```

This ensures the system always has a **strict upper bound** on notification count.

## 3. Heuristic for important push (needs-action + INBOX)

Emails requiring user action are detected using the `keywords` field.

Emails containing the keyword `"needs-action"` are considered actionable.

```dart
bool isActionRequiredEmail(PresentationEmail email) {
  final keywords = email.keywords;
  if (keywords == null) return false;
  return keywords[KeyWordIdentifier('needs-action')] == true;
}
```

Regular emails only generate notifications if they belong to the **Inbox mailbox**.

```dart
bool isInboxEmail(PresentationEmail email, MailboxId inboxMailboxId) {
  return email.mailboxIds?.containsKey(inboxMailboxId) ?? false;
}
```

The inbox `MailboxId` must be resolved upstream from the mailbox list before calling this helper — `PresentationEmail` stores only `mailboxIds` and has no knowledge of which one is the Inbox.

### Optimized Notification Selection Algorithm

To efficiently select notifications from large bursts of emails, the system keeps only the **top 20 most relevant emails**.

Selection priority:

1. actionable emails (`needs-action`)
2. newest **Inbox emails**

Emails outside the Inbox mailbox will not generate notifications unless they are actionable.

Example implementation:

```dart
import 'package:collection/collection.dart';

List<PresentationEmail> selectEmailsForNotification(
  List<PresentationEmail> emails,
  MailboxId inboxMailboxId,
) {
  const maxNotifications = 20;

  final actionEmails =
      emails.where((e) => isActionRequiredEmail(e))
          .take(maxNotifications)
          .toList();

  final remainingSlots = maxNotifications - actionEmails.length;

  final heap = HeapPriorityQueue<PresentationEmail>(
    (a, b) => a.receivedAt.compareTo(b.receivedAt),
  );

  for (final email in emails) {
    if (isActionRequiredEmail(email)) continue;
    if (!isInboxEmail(email, inboxMailboxId)) continue;

    heap.add(email);

    if (heap.length > remainingSlots) {
      heap.removeFirst();
    }
  }

  final newestInboxEmails = heap.toList()
    ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

  return [...actionEmails, ...newestInboxEmails];
}
```

Time complexity: `O(n log 20) ≈ O(n)`

## 4. Fix local notification removal error

The notification removal logic will be updated to handle failures safely.

Current implementation:

```dart
await _localNotificationsPlugin.cancel(id.hashCode);
```

Improved implementation:

```dart
Future<void> removeNotification(String id) async {
  try {
    await _localNotificationsPlugin.cancel(id.hashCode);
  } catch (e) {
    logWarning("cancel notification failed: $e");
  }
}
```

This ensures notification removal failures do not interrupt the notification pipeline.

# Architecture Flow (after fix)

```text
FCM message
   ↓
handleFirebaseBackgroundMessage
   ↓
[skip if app in foreground]
   ↓
FcmMessageController
   ↓
EmailChangeListener
   ↓
Notification selection limiter (heuristic + max 20)
   ↓
LocalNotificationManager
   ↓
Safe notification removal
```

# Code Changes

## 1. FcmMessageController / handleFirebaseBackgroundMessage

Skip notification display when app is in foreground.

## 2. EmailChangeListener

Limit notifications using the selection algorithm.

```dart
final selectedEmails = selectEmailsForNotification(emailList);

for (final email in selectedEmails) {
  LocalNotificationManager.instance.showPushNotification(
    id: email.id?.id.value ?? '',
    title: email.subject ?? '',
    message: email.preview,
  );
}
```

## 3. Foreground email synchronization

Update delivery state when saving email state cache.

```dart
FCMCacheManager.storeStateToRefresh(
  accountId,
  userName,
  TypeName.emailDelivery,
  newState,
);
```

## 4. LocalNotificationManager

Add defensive notification cancellation.

```dart
Future<void> removeNotification(String id) async {
  try {
    await _localNotificationsPlugin.cancel(id.hashCode);
  } catch (e) {
    logWarning("cancel notification failed: $e");
  }
}
```

# Alternatives

The following approaches were considered but will **not** be implemented in this iteration (WON'T items from MoSCoW).

## Debounce on app side

Introduce a 30-second debounce window in the background push handler so that only the first push in a burst is processed.

This approach is no longer prioritised because the other MUST/SHOULD steps already eliminate the storm. Once notification display is skipped in foreground and the count is capped at 20, a residual burst during background reconnection is an edge case that does not justify the added complexity.

## Separate subscription for `resync` and `notifs`

Currently the same FCM subscription is used both to trigger a background resync and to generate visible notifications. Separating these would allow finer control (e.g. suppress notification-generating pushes while still allowing resync pushes).

This is deferred because it is correlated with a broader app-removal / subscription-cleanup initiative and should be tackled together.

**Open question:** For resync, is FCM actually necessary? If the app only uses FCM to leverage an offline cache, an alternative would be to drop FCM entirely for resync and replace it with a WebSocket connection when the app is in foreground. This would remove a whole class of background-push issues and is worth evaluating as part of the subscription-separation work.

# Consequences

## Positive

* Prevents Android notification storms
* Guarantees maximum **20 notifications per burst**
* Reduces device overload
* Improves notification relevance by prioritizing actionable and Inbox emails
* No notifications shown when user is already in the app

## Negative

* Some emails may not generate notifications during bursts
* Requires product validation for the heuristic (`needs-action` + INBOX priority)

# References

* [tmail-backend#2301 — Use `collapse_key` for push notifications](https://github.com/linagora/tmail-backend/issues/2301) — Backend issue describing how `collapse_key` is configured server-side to collapse queued push messages on device reconnect
