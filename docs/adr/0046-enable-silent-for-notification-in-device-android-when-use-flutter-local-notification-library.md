# 46. Enable `silent` for notification in device android when use flutter_local_notification library

Date: 2024-05-10

## Status

- Issue:
  - [Notification flood](https://github.com/linagora/tmail-flutter/issues/2599)

## Context

- According to the official documentation of [flutter_local_notification](https://pub.dev/packages/flutter_local_notifications#-android-setup). 
For Android 8.0+, sounds and vibrations are associated with notification channels and can only be configured when they are first created.
And it cannot be changed unless creating a new channel or reinstalling the application.
- So how can we only turn on the sound and vibration of one notification and turn it off for the remaining notifications when we display them at the same time?
- From version [v16.2.0](https://pub.dev/packages/flutter_local_notifications/changelog#1620) of flutter_local_notifications added the `silent` property to the `AndroidNotificationDetails` that allows specifying a notification on Android to be silent even if associated the notification channel allows for sounds to be played.

## Decision

- Set 
  - `silent=true` for all notifications with id `EmailId` 
  - `silent=false` for notifications with id `GroupdId`.

## Consequences

- There is only one notification with sound and vibration in the received notification list at the same time.
