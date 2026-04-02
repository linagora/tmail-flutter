# 0075. Fix load more not triggered on iOS when fast scrolling to bottom

Date: 2026-03-31

## Status

- Issues:
  - [TF-4425 Bug: load more is not working](https://github.com/linagora/tmail-flutter/issues/TF-4425)

## Context

On iOS 18, `handleLoadMoreEmailsRequest()` was never called when users fast-scrolled to the bottom of the email list.

**Root cause:** iOS uses `BouncingScrollPhysics`, which allows `pixels` to overshoot `maxScrollExtent` during fast scrolls. The scroll listener used an exact equality check:

```dart
scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent
```

This condition is **never true** on iOS when overscrolling — `pixels > maxScrollExtent` at the moment `ScrollEndNotification` fires, and no second `ScrollEndNotification` is emitted once the content snaps back.

Android is unaffected because `ClampingScrollPhysics` clamps `pixels` within `[0, maxScrollExtent]`.

iOS 18 increased scroll momentum, making this overshoot more frequent.

## Decision

Replace `==` with `>=` in the scroll notification listener:

```dart
bool _handleScrollNotificationListener(ScrollNotification scrollInfo) {
  if (scrollInfo is ScrollEndNotification &&
      scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent &&
      !controller.loadingMoreStatus.value.isRunning &&
      scrollInfo.metrics.axisDirection == AxisDirection.down
  ) {
    controller.handleLoadMoreEmailsRequest();
  }
  return false;
}
```

The existing `isRunning` guard prevents duplicate load-more requests.

## Consequences

- Load more works correctly on iOS 18 with fast scrolling.
- No behavior change on Android.
- No risk of duplicate requests due to the existing `isRunning` guard.
