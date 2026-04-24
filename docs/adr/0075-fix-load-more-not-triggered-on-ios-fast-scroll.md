# 0075. Fix load more not triggered on iOS when fast scrolling to bottom

Date: 2026-03-31

## Status

- Issues:
  - [TF-4425 Bug: load more is not working](https://github.com/linagora/tmail-flutter/issues/TF-4425)

## Context

On iOS, `handleLoadMoreEmailsRequest()` was never triggered when users scrolled to the bottom of the email list. The original condition used exact equality:

```dart
scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent
```

**Root cause:** iOS uses `BouncingScrollPhysics` (spring-based simulation), which causes `pixels` to either overshoot or settle slightly short of `maxScrollExtent` depending on scroll speed and device performance. In both cases, `ScrollEndNotification` fires when `pixels != maxScrollExtent`, so the condition is never satisfied.

This behavior is device-dependent — newer/faster devices (iPhone 13 Pro Max, iOS 18) are less affected, while older/slower devices (iPhone 7, iOS 15) exhibit larger deviations. Android is unaffected because `ClampingScrollPhysics` clamps `pixels` exactly within `[0, maxScrollExtent]`.

## Decision

Apply `ClampingScrollPhysics` on iOS only, and replace `==` with `>=`:

```dart
// physics
physics: PlatformInfo.isIOS
    ? const ClampingScrollPhysics()
    : const AlwaysScrollableScrollPhysics(),

// condition
scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent
```

`ClampingScrollPhysics` ensures `pixels` is clamped exactly to `maxScrollExtent` at the boundary, making the condition deterministic. The `>=` adds a defensive guard for any residual edge cases.

## Consequences

- Load more works correctly across all iOS versions and device generations.
- No behavior change on Android or Web.
- iOS loses the native bounce feel at list boundaries. Acceptable for an email list UI.
- No risk of duplicate requests due to the existing `isRunning` guard.
