# 42. Fix error `Failed to execute 'subscribe' on 'PushManager': Subscription failed - no active Service Worker` when get token on web

Date: 2024-04-02

## Status

- Issues: 
  - https://github.com/firebase/firebase-js-sdk/issues/7575
  - https://github.com/firebase/firebase-js-sdk/issues/7693

## Context

- Sometimes calling messaging `FirebaseMessaging.onMessage.getToken()` returns the error `Failed to execute 'subscribe' on 'PushManager': Subscription failed - no active Service Worker`.
- It seems to occur on the first page load and clear storage with unregister service worker, when the user refreshes the notifications work and there's no error anymore.

## Decision

- There is currently no official solution from the [Firebase](https://github.com/firebase/firebase-js-sdk) team.
- So we will use the following workaround:
  - If `FirebaseMessaging.onMessage.getToken()` throw `DomException` then call again get token. 
  - Try again 3 times with `FirebaseMessaging.onMessage.getToken()`
  
## Consequences

- We got the token right after trying again.
- Receiving new messages on `foreground` and `background` works fine.
