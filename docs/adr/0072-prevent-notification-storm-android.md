# 72. Prevent notification storm on Android

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

To prevent notification storms, we introduce **four defensive mechanisms**.

# 1. Push debounce in background handler (30s window)

The background push handler introduces a **30-second debounce window**.

If multiple push events arrive within this window, only the first push will be processed.

The timestamp of the last processed push is stored using `SharedPreferences`.

Example implementation:

```dart
Future<bool> shouldProcessPush() async {
  final prefs = await SharedPreferences.getInstance();

  final lastTime = prefs.getInt('last_push_processed_time');
  final now = DateTime.now().millisecondsSinceEpoch;

  if (lastTime != null && now - lastTime < 30000) {
    return false;
  }

  await prefs.setInt('last_push_processed_time', now);

  return true;
}
```

Usage:

```dart
Future<void> handleFirebaseBackgroundMessage(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (!await shouldProcessPush()) {
    return;
  }

  FcmService.instance.handleFirebaseBackgroundMessage(message);
}
```

This mechanism prevents repeated push bursts from triggering the notification pipeline multiple times.

## Background execution constraints

The FCM background handler runs inside a short-lived Flutter isolate.

Background handlers are designed to execute quickly and may be terminated by the Android system at any time after the push event is delivered.

Because of this limitation, long-running operations such as delaying processing for an aggregation window (for example waiting 1 minute before generating notifications) are not reliable.

If the isolate is terminated before the delay completes, notifications may never be generated.

For this reason, the system uses a lightweight debounce mechanism that immediately processes the first push event and ignores subsequent push events during a short time window.

# 2. Notification limiter

When a push burst is processed, the system limits the number of generated notifications.

Rules:

* maximum **20 notifications**
* prioritize emails requiring user action
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

# Action-required Email Detection

Emails requiring user action are detected using the `keywords` field.

Example structure:

```dart
final Map<KeyWordIdentifier, bool>? keywords;
```

Emails containing the keyword `"needs-action"` are considered actionable.

Example:

```dart
keywords[KeyWordIdentifier('needs-action')] == true
```

Helper function:

```dart
bool isActionRequiredEmail(PresentationEmail email) {
  final keywords = email.keywords;
  if (keywords == null) return false;

  return keywords[KeyWordIdentifier('needs-action')] == true;
}
```

# Inbox Email Detection

Regular emails will only generate notifications if they belong to the **Inbox mailbox**.

Helper function:

```dart
bool isInboxEmail(PresentationEmail email) {
  return email.mailboxIds?.contains("inbox-id") ?? false;
}
```

# Optimized Notification Selection Algorithm

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
    if (!isInboxEmail(email)) continue;

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

Time complexity:

```text
O(n log 20) ≈ O(n)
```

This avoids sorting the entire email list when bursts contain many emails.

# 3. Update delivery state during foreground synchronization

The application already stores the **email delivery state** when push notifications are processed.

To ensure state consistency, the delivery state will also be updated when the email state cache is updated during **foreground synchronization**.

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

This ensures the latest delivery state is always persisted, even when updates originate from foreground synchronization.

# 4. Fix local notification removal error

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
(push debounce)
   ↓
FcmMessageController
   ↓
EmailChangeListener
   ↓
Notification selection limiter
   ↓
LocalNotificationManager
   ↓
Safe notification removal
```

# Code Changes

## 1. handleFirebaseBackgroundMessage

Add push debounce logic.

```dart
if (!await shouldProcessPush()) {
  return;
}
```

## 2. EmailChangeListener

Limit notifications using the selection algorithm.

```dart
final selectedEmails =
    selectEmailsForNotification(emailList);

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

# Consequences

## Positive

* Prevents Android notification storms
* Guarantees maximum **20 notifications per burst**
* Reduces device overload
* Improves notification relevance by prioritizing Inbox emails

## Negative

* Some emails may not generate notifications during bursts
* Notifications may be delayed due to push debounce

However this trade-off significantly improves system stability.

# Future Improvements

Possible enhancements:

## Notification digest

Instead of multiple notifications:

```text
You have 120 new emails
```

## Server-side push aggregation

The server may send multiple email IDs in a single push event.

## Adaptive rate limiting

Adjust notification limits depending on:

* device performance
* Android version
* notification load
