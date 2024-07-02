# 50. Android notification permission check

Date: 2024-06-07

## Status

Accepted

## Context

- User need a way to tell the notification configuration in-app
- Current method from `permission_handler` library is not enough to tell the exact permission status due to the fact that it does not support checking the specific notification group's status, which also affects the notification functionality alongside with the app's main toggle

## Decision
New method is written in Kotlin for Android side only, to handle this permission check more precisely
- For Android 28 or above, `getNotificationChannelGroup()` and its API `isBlocked` is supported to check if a specific notification group is disabled or not
- For Android lower than 28, a simple check by `areNotificationsEnabled()` is enough

## Consequences
The permission's status is better reflect on the Twake Mail app.