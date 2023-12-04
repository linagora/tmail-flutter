# 17. Register firebase registration token guideline

Date: 2023-11-24

## Status

Accepted

## Context

The logic of firebase registration is complicated to follow by all developers

## Decision

Brief the logic flows to easier in following the changes of firebase registration implementation

- `onFcmTokenChanged`: Listen for token changes from FCM (Firebase Cloud Message)
- If there is a new `token`, we will send a request to the jmap server to check if this token has been registered `GetFirebaseRegistrationByDeviceIdInteractor`.
`deviceClientId` is a unique key generated based on `token` and `platform`
- On the contrary, if no new token is generated, we will retrieve the `deviceClientId` stored in `cache` to call back the request to the above jmap server.
- If the status after sending the request to the jmap server returns successful `GetFirebaseRegistrationByDeviceIdSuccesss`. 
We perform a check to see if `FirebaseRegistrationTokenExpired` has expired or not (The check is performed before `3 days`). 
If it expires, we will send a request to update `expires` for this `FirebaseRegistration` to increase the lifetime by `7 more days`.
- Conversely, if we receive `GetFirebaseRegistrationByDeviceIdFailure` we will send a request to register a new `FirebaseRegistration`

## Consequences

- Any change to `Push notifcation` should be updated in this ADR
