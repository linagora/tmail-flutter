# 51. Push notification click logic on iOS

Date: 2024-06-07

## Status

Accepted

## Context

On iOS, we use `Notification Service Extension` [NSE](https://developer.apple.com/documentation/usernotifications/modifying-content-in-newly-delivered-notifications) to modify email content first when displaying push notifications to users.
- In NSE we have implemented getting `new email list` based on `EmailDeliveryState` sent from FCM.
- NSE only modifies and displays 1 notification, so we will display the notification for the last email in the list via NSE (is called `RemoteNotification`). 
For the remaining emails we will use [UNUserNotificationCenter](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter) to automatically display notifications (is called `LocalNotification`).

## Decision

Brief the logic flows when clicking notifications:

1. Foreground/Background state

- When clicking on notifications (both LocalNotification and RemoteNotification) the `didReceive` function of `UNUserNotificationCenter` in `AppDelegate` will be called.

```swift
 override func userNotificationCenter(
    _ center: UNUserNotificationCenter, 
    didReceive response: UNNotificationResponse, 
    withCompletionHandler completionHandler: @escaping () -> Void
 ) {}
```

`response.notification.request.content.userInfo` is the contents of the push payload notification.
We use `FlutterMethodChannel` to pass `UserInfo` from iOS native code to Flutter dart code

```swift
  self.notificationInteractionChannel?.invokeMethod("current_email_id_in_notification_click_when_app_foreground_or_background", arguments: response.notification.request.content.userInfo)
```

2. Terminated state

- With `RemoteNotification`, we will get the push notification payload through `launchOptions?[.remoteNotification]` in the `didFinishLaunchingWithOptions` function of `AppDelegate`

```swift
override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
) -> Bool {}
```

Save it in a `remoteNotificationPayload` variable in memory and use `FlutterMethodChannel` to retrieve it every time you open the app.

```swift
self.notificationInteractionChannel?.setMethodCallHandler { (call, result) in
    switch call.method {
        case "current_email_id_in_notification_click_when_app_terminated":
            result(self.remoteNotificationPayload)
            self.remoteNotificationPayload = nil
        default:
            break
    }
}
```

- As for `LocalNotification`, we will receive the push notification payload at the `didReceive` function of `UNUserNotificationCenter` (similar to `Foreground/Background state`)

```swift
 override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
) {
    self.remoteNotificationPayload = response.notification.request.content.userInfo
 }
```

## Consequences

- The application is correctly adjusted to the detailed screen email when clicking on the notification.
- Any changes to the click push notification logic must be updated in this ADR.
