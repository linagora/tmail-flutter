# 47. FCM iOS push configuration confirmation

Date: 2024-05-14

## Status

Accepted

## Context

- When new email comes, the mobile app, specifically iOS app, needs to show users push notification
- The notification's content need to be modified on client side before showing to the users
  - According to [this doc](https://developer.apple.com/documentation/usernotifications/unnotificationserviceextension#overview)
    > Your app has configured the remote notification to display an alert.
    
    > The remote notification’s aps dictionary includes the mutable-content key with the value set to 1.
    
    > You can’t modify silent notifications or those that only play a sound or badge the app’s icon.
  - And according to [this doc](https://developer.apple.com/documentation/usernotifications/generating-a-remote-notification#Payload-key-reference)
    > content-available: The background notification flag. To perform a silent background update, specify the value 1 and **don’t include the alert**, badge, or sound keys in your payload.
- However, in the notification payload fired by BE, `content-available` flag is present, along with `mutable-content` flag and `alert` object. This confuse the iOS system when the messages come, which sometimes causes the system to translate the notification as background or silent, which is undesired. Whenever the notification is detected as silent, iOS will not trigger push notification.

## Decision
When new emails come, the BE will fire notification payload without `content-available` flag.

## Consequences
1. The iOS will translate the notification message as expected, results in no missing push notification
2. TODO: Test this changes by:
   1. Build the iOS app on MacOS with release mode on real iPhone, login and when the app is in email view, put the app in background mode or kill the app. Leave the phone plugged into MacOS machine.
   2. Open XCode > Window > Devices & Simulators, choose the iPhone currently plugged in, choose "Open Console" and start streaming log
   3. Use TMail from the web to send an email to self, expected to see `[com.linagora.ios.teammail] Received remote notification request <ID> [ waking: 0, hasAlertContent: 1, hasSound: 0 hasBadge: 0 hasContentAvailable: 0 hasMutableContent: 1 pushType: Alert]` in the Console app after no longer than 1 minute
   4. The iPhone should received a push notification not long after, and inside the Console app should print out the information about `com.linagora.ios.teammail.TwakeMailNSE` works.