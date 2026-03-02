# 71. Fix memory leaks: consumeState() subscriptions, ever() workers, and unbounded fetch limit

Date: 2026-03-02

## Status

Accepted

PR: [fix/memory-optimize-subscriptions-workers-fetch-limit #4353](https://github.com/linagora/tmail-flutter/pull/4353)

## Context

Three independent memory leaks were identified through static analysis of the controller lifecycle:

### 1. Leaked `StreamSubscription` in `BaseController.consumeState()`

`BaseController.consumeState()` was called in ~352 places across 80+ files. Each call to
`Stream.listen()` returns a `StreamSubscription` that must be cancelled to release the stream
reference and allow GC. The previous implementation discarded the returned subscription:

```dart
// Before – subscription handle is lost
void consumeState(Stream<Either<Failure, Success>> newStateStream) {
  newStateStream.listen(onData, onError: onError, onDone: onDone);
}
```

Because no reference was kept, the subscription could never be cancelled in `onClose()`, causing
every controller to retain a live reference to its upstream stream after it was closed.

### 2. Undisposed `ever()` workers in `ThreadController`

`ThreadController._registerObxStreamListener()` created 6 `Worker` objects via GetX `ever()`.
The return values were discarded:

```dart
// Before – Worker objects are lost
ever(mailboxDashBoardController.selectedMailbox, (mailbox) { ... });
ever(searchController.searchState, (searchState) { ... });
// ... 4 more
```

GetX only auto-disposes `Worker`s for controllers registered in its DI container. Directly
instantiated controllers (the common case in tests and some runtime paths) are not covered.
Undisposed workers continue to fire their callbacks even after the owning controller is closed,
executing stale logic against a destroyed controller.

### 3. Unbounded `limitEmailFetched` in `ThreadController`

`ThreadController._peakEmailCount` tracked the highest email list size ever seen and was used
as the `limit` parameter for JMAP `Email/get` refresh requests. There was no upper bound, so a
user who scrolled through a very large mailbox would permanently cause every subsequent refresh
to request an arbitrarily large number of emails.

### 4. Retained completed subscriptions in `BaseController`

After fix #1, subscriptions were tracked and cancelled on `onClose()`, but short-lived streams
were still kept in the tracking collection until controller disposal. For long-lived controllers
that frequently call `consumeState()` (e.g. many request/response cycles), this can grow memory
usage even though those streams already completed.

## Decision

### Fix 1 – Collect, auto-untrack, and cancel `StreamSubscription`s in `BaseController`

Add a `_stateSubscriptions` tracking map to `BaseController`. `consumeState()` stores each
`StreamSubscription`, removes it automatically when the stream completes, and `onClose()`
cancels and clears all remaining active subscriptions before delegating to `super.onClose()`.

```dart
final _stateSubscriptions = <Object, StreamSubscription<Either<Failure, Success>>>{};

void consumeState(Stream<Either<Failure, Success>> newStateStream) {
  final key = Object();
  final subscription = newStateStream.listen(
    onData,
    onError: onError,
    onDone: () {
      scheduleMicrotask(() => _stateSubscriptions.remove(key));
      onDone();
    },
  );
  _stateSubscriptions[key] = subscription;
}

@override
void onClose() {
  for (final sub in _stateSubscriptions.values.toList()) {
    sub.cancel();
  }
  _stateSubscriptions.clear();
  // ... existing browser subscriptions ...
  super.onClose();
}
```

This fix propagates to all 80+ subclasses automatically with zero call-site changes.

### Fix 2 – Store and dispose `ever()` workers in `ThreadController`

Add a `_workers` list to `ThreadController`. Every `ever()` call in
`_registerObxStreamListener()` is wrapped with `_workers.add(...)`. `onClose()` disposes all
workers before the rest of its cleanup.

```dart
final _workers = <Worker>[];

// In _registerObxStreamListener():
_workers.add(ever(mailboxDashBoardController.selectedMailbox, (mailbox) { ... }));
// ... same for the other 5 ever() calls

@override
void onClose() {
  for (final w in _workers) {
    w.dispose();
  }
  _workers.clear();
  // ... rest of existing cleanup ...
  super.onClose();
}
```

### Fix 3 – Cap `limitEmailFetched` with `ThreadConstants.maxRefreshLimit`

Add `maxRefreshLimit = 100` to `ThreadConstants`. The `limitEmailFetched` getter clamps
`_peakEmailCount` to this ceiling:

```dart
// In ThreadConstants:
static const int maxRefreshLimit = 100;

// In ThreadController:
UnsignedInt get limitEmailFetched {
  if (_peakEmailCount == 0) return ThreadConstants.defaultLimit;
  return UnsignedInt(_peakEmailCount.clamp(1, ThreadConstants.maxRefreshLimit));
}
```

## Tests

All three fixes were developed using TDD (failing test written before implementation):

- **`test/memory/base_controller_subscription_test.dart`** (new) — verifies:
  - active subscriptions are untracked when streams complete;
  - events stop arriving in `onData` after `onClose()` is called.
- **`test/features/thread/.../thread_controller_test.dart`** — two new test groups:
  - `limitEmailFetched` cap: asserts `UnsignedInt(maxRefreshLimit)` when peak exceeds the limit.
  - `ever() worker disposal`: asserts `_peakEmailCount` does not change after `onClose()`.

## Consequences

### Positive

- Prevents stream references from accumulating when long-lived streams (WebSocket, push
  notifications) outlive short-lived controllers.
- Eliminates stale `ever()` callbacks executing on closed `ThreadController` instances.
- Bounds JMAP `Email/get` request size to a predictable maximum regardless of mailbox size.
- No call-site changes required across the 352 `consumeState()` call sites.
- All 1 371 existing tests continue to pass.

### Negative

- `BaseController` now holds a mutable tracking map for active subscriptions. The overhead is
  negligible and bounded by currently active streams.
- `ThreadController` holds a `_workers` list with 6 entries; again negligible.

## Files Changed

- `lib/features/base/base_controller.dart` — active `_stateSubscriptions` tracking map; updated `consumeState()` and `onClose()`
- `lib/features/thread/presentation/thread_controller.dart` — `_workers` list; updated `_registerObxStreamListener()` and `onClose()`; capped `limitEmailFetched`
- `lib/features/thread/domain/constants/thread_constants.dart` — added `maxRefreshLimit = 100`
- `test/memory/base_controller_subscription_test.dart` — new subscription lifecycle test
- `test/features/thread/presentation/controller/thread_controller_test.dart` — two new test groups; pre-existing test fixes
