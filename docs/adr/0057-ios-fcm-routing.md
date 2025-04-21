# 57. iOS FCM routing

Date: 2024-12-05

## Status

Accepted

## Context

- Notification from FCM contains `mutable-content: true`
- Those notification will be transfered to Notification Service Extension ([See here](https://developer.apple.com/documentation/usernotifications/modifying-content-in-newly-delivered-notifications#Configure-the-payload-for-the-remote-notification)) whether the app is in background or foreground
- Due to the app is in foreground, no notification will be shown
- Due to NSE handle the data, FCM on Flutter side cannot handle it

## Decision

- We check if the app is in foreground or not
  - If the app is in foreground, we will not modify the payload and route the payload to FCM foreground method channel
  - If the app is in background or terminated, we will keep the current implementation

## Consequences

- Twake Mail iOS app will get latest updates when app is in foreground
