# 33. Disable work manager in sending email automatically

Date: 2024-01-12

## Status

Accepted

## Context

- In some Wifi environments, network connection status not return the right value
- We can not manage the schedule of sending email well (it depends on the Android scheduler)

## Decision

- Disable work manager in sending email automatically
- The status of network in be check directly with `InternetConnectionChecker.hasConnection`
```dart
  Future<bool> hasInternetConnection() {
    return _internetConnectionChecker.hasConnection;
  }
```

## Consequences

- If user send message when network is not available, message will be cached and then
- User can resend message manually when network is available
- User can edit/delete cached messages
