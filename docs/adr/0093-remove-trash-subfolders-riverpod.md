# 93. Remove trash subfolders on empty-trash via Riverpod

Date: 2026-06-03

## Status

Accepted

## Related ADRs

- [ADR-0092](./0092-upgrade-flutter-riverpod-3.md) — upgraded to Riverpod 3.x, introduced `UncontrolledProviderScope`, frozen `appProviderContainer` rule

## Context

### The problem

When a user empties the Trash mailbox, only the emails inside Trash were deleted. Any child mailboxes (subfolders) created under Trash were silently left behind — they were never removed. The expected behaviour: emptying Trash deletes all emails **and** all subfolders.

### Why this is hard to add to the existing GetX flow

`emptyTrashFolderAction` in `MailboxDashBoardController` was a single monolithic method: it chose between `ClearMailboxInteractor` (JMAP clear) or `EmptyTrashFolderInteractor` (email-by-email deletion) and emitted the result to `consumeState`. Adding subfolder deletion required sequencing two async interactors and collating their results — a pattern that does not fit the existing `consumeState` stream model cleanly.

### Why Riverpod fits here

ADR-0092 established the architectural direction: Riverpod is the layer for managing async state that the widget tree needs to observe. `@riverpod Notifier` provides:

- explicit async sequencing inside a single `execute()` method
- `ref.mounted` to safely guard state mutations after `await`
- a sealed state machine (`EmptyTrashState`) that the UI pattern-matches on
- unit-testable logic via `ProviderContainer` overrides, with no need for GetX bindings

## Architecture comparison: before vs after

### Before — monolithic method in `MailboxDashBoardController`

```
emptyTrashFolderAction()
  │
  ├── accountId == null?  ──► consumeState(Left(EmptyTrashFolderFailure))
  ├── session == null?    ──► consumeState(Left(EmptyTrashFolderFailure))
  ├── trashFolder == null? ─► consumeState(Left(EmptyTrashFolderFailure))
  │
  ├── JMAP clear supported AND not team folder?
  │       └── clearMailbox(session, accountId, id, role)
  │               └── consumeState(stream of ClearMailboxInteractor)
  │
  └── else
          └── consumeState(_emptyTrashFolderInteractor.execute(
                session, accountId, id, count, progressCtrl))
```

Problems with this approach:

| Problem | Detail |
|---|---|
| Sequential async impossible | `consumeState` pipes a single stream into the GetX `viewState` observable. There is no clean place to sequence a *second* async operation (subfolder deletion) after the first completes |
| Business logic in the controller | The capability check (`jmapMailboxClear.isSupported`), the team-folder guard, the session/account null checks, and the strategy selection are all mixed into a presentation controller |
| Subfolders ignored entirely | The old code had no path to delete child mailboxes at all |
| Untestable without GetX | Testing required wiring `EmptyTrashFolderInteractor` through GetX bindings; no way to override a single interactor in isolation |

### After — Riverpod Notifier + stream bridge

```
emptyTrashFolderAction()          ← GetX controller, unchanged API
  │
  └── _emptyTrashStreamController.add(trashMailbox)   ← just emit, nothing else

emptyTrashRequestedProvider       ← Riverpod, wraps the stream
  │
  ref.listen (MailboxProviderListenerWidget)
  │
  _executeEmptyTrash()            ← widget reads session/accountId from controller,
  │                                  computes childIds + useJmapClear flag
  │
  EmptyTrashNotifier.execute()    ← pure async orchestrator, no GetX
  │
  ├── countTotalEmails == 0  ──► skip email step
  ├── useJmapClear            ──► _clearMailbox()
  └── else                    ──► _emptyTrashByEmailDeletion()
                                        │
                                  (if childIds.isNotEmpty)
                                        └── _deleteSubfolders()
                                                  │
                                            EmptyTrashState (sealed)
                                                  │
                                    ref.listen (MailboxProviderListenerWidget)
                                                  │
                              toasts + progress + RefreshAllMailboxAction
```

What changed structurally:

| Concern | Before | After |
|---|---|---|
| Who picks the clearing strategy | `MailboxDashBoardController` | `MailboxProviderListenerWidget` (reads capability from session) |
| Who sequences email clear + subfolder delete | Nobody (impossible) | `EmptyTrashNotifier.execute()` |
| Who handles result | `consumeState` → scattered `_emptyTrashFolderSuccess` / `_clearMailboxSuccess` handlers | `MailboxProviderListenerWidget._handleEmptyTrashStateChange` (single exhaustive switch) |
| How to test | Mock interactors via GetX.put() before instantiating the controller | `ProviderContainer(overrides: [...])` — no GetX at all |
| Controller responsibility | Picks strategy, calls interactors, handles results | Emits a trigger event, nothing more |

---

## Decision

Implement the empty-trash + subfolder-deletion flow as a `@riverpod Notifier` (`EmptyTrashNotifier`). Bridge it to the existing GetX trigger path via a broadcast stream on the GetX controller. Wire the UI reaction in a dedicated `ConsumerWidget` that wraps the mailbox list.

## Architecture

### High-level data flow

```
User taps "Empty Trash"
       │
       ▼
MailboxItemConsumerWidget.onEmptyMailboxActionCallback
       │  (calls)
       ▼
MailboxActionHandlerMixin.emptyTrashAction          ← shows confirmation dialog
       │  (on confirm, calls)
       ▼
MailboxDashBoardController.emptyTrashFolderAction
       │  (adds PresentationMailbox to)
       ▼
_emptyTrashStreamController (broadcast StreamController)
       │  (exposed as)
       ▼
emptyTrashRequestedProvider  (Stream<PresentationMailbox> via @riverpod)
       │  (ref.listen in)
       ▼
MailboxProviderListenerWidget._executeEmptyTrash
       │  (calls)
       ▼
EmptyTrashNotifier.execute(session, accountId, trashMailbox, childIds, useJmapClear)
       │
       ├── trashMailbox.countTotalEmails == 0  ──► skip email clearing
       │
       ├── useJmapClear  ──► _clearMailbox (ClearMailboxInteractor)
       │                                  │
       └── else          ──► _emptyTrashByEmailDeletion (EmptyTrashFolderInteractor)
                                          │
                    (if childIds.isNotEmpty)
                                          ▼
                           _deleteSubfolders (DeleteMultipleMailboxInteractor)
                                          │
                                          ▼
                                 EmptyTrashState (sealed)
                                          │
                             ref.listen in MailboxProviderListenerWidget
                                          │
                    ┌─────────────────────┼────────────────────┐
                    ▼                     ▼                     ▼
             EmptyTrashLoading     EmptyTrashSuccess      EmptyTrashFailure
             (progress bar)     (toasts + refresh)     (error toast + urgent handler)
```

### Component responsibilities

| Component | Layer | Responsibility |
|---|---|---|
| `MailboxDashBoardController._emptyTrashStreamController` | GetX Presentation | Trigger source; emits `PresentationMailbox` when the user confirms |
| `emptyTrashRequestedProvider` | Riverpod Presentation | Wraps the stream as a Riverpod provider so `ConsumerWidget`s can listen |
| `EmptyTrashNotifier` | Riverpod Presentation | Orchestrates the three-step async flow; owns `EmptyTrashState` |
| `MailboxProviderListenerWidget` | Riverpod Presentation | Bridges Riverpod state back to GetX controller side effects (toasts, progress, mailbox refresh) |
| `MailboxItemConsumerWidget` | Flutter Presentation | Wraps `MailboxItemWidget` + `Obx` so `BaseMailboxView` can host `MailboxProviderListenerWidget` without a `ConsumerWidget` ancestor conflict |

---

## Key design decisions

### 1. Stream bridge: GetX → Riverpod

`MailboxDashBoardController` owns a `StreamController<PresentationMailbox>.broadcast()`. Instead of calling interactors directly, `emptyTrashFolderAction` now just adds to this stream:

```dart
// Before
clearMailbox(session, accountId, trashFolder.id, PresentationMailbox.roleTrash);
// or
consumeState(_emptyTrashFolderInteractor.execute(...));

// After
_emptyTrashStreamController.add(trashFolder);
```

`emptyTrashRequestedProvider` wraps this stream:

```dart
@riverpod
Stream<PresentationMailbox> emptyTrashRequested(Ref ref) =>
    Get.find<MailboxDashBoardController>().onEmptyTrashRequested;
```

**Why a stream and not a simple method call?**

Multiple code paths trigger empty-trash: from the mailbox panel (sidebar), from the thread view banner, and from the search mailbox controller. All of them already funnel through `MailboxDashBoardController.emptyTrashFolderAction`. Using a stream lets every caller remain unchanged — they call the same GetX method, and the Riverpod layer reacts to the emission automatically, regardless of which code path triggered it.

### 2. Sealed classes — what they are and why we use them here

#### What is a sealed class?

A `sealed` class in Dart (introduced in Dart 3.0) is a class that restricts which other classes may extend or implement it. **All direct subtypes must be declared in the same library file.** The compiler knows the complete, closed set of subtypes at compile time.

```dart
// Declare the sealed base
sealed class EmptyTrashState { const EmptyTrashState(); }

// All subtypes must be in the same file
class EmptyTrashIdle    extends EmptyTrashState { const EmptyTrashIdle(); }
class EmptyTrashLoading extends EmptyTrashState { const EmptyTrashLoading(); }
class EmptyTrashSuccess extends EmptyTrashState { ... }
class EmptyTrashFailure extends EmptyTrashState { ... }
```

Any attempt to extend `EmptyTrashState` from another file produces a **compile error**. The set is permanently closed.

#### The key property: exhaustive pattern matching

Because the compiler knows every subtype, a `switch` on a sealed class must cover all cases. If you add a new subtype later and forget to handle it somewhere, the compiler reports an error — not a runtime crash.

```dart
// This switch is exhaustive — the compiler enforces it
switch (state) {
  case EmptyTrashLoading():
    // show progress bar
  case EmptyTrashSuccess(:final clearedEmailIds, :final subfoldersStatus):
    // show toast, refresh
  case EmptyTrashFailure(:final exception):
    // show error toast
  case EmptyTrashIdle():
    break;
  // No default: needed — compiler guarantees coverage
}
```

If a fifth subtype `EmptyTrashCancelled` were added and this switch were not updated, the file would **not compile**.

#### Why not use an abstract class or enum?

| Approach | Problem |
|---|---|
| `abstract class` with `is` checks | No exhaustiveness guarantee; adding a new subtype silently breaks all unhandled `is` chains at runtime |
| `enum` | All variants must be instances of the same type with no custom fields; cannot carry `List<EmailId>` or `Object?` exception per-variant |
| `sealed class` | Subtypes are distinct classes that carry their own fields; compiler enforces exhaustive handling everywhere a switch is written |

#### The two sealed hierarchies in this feature

**Public state — `EmptyTrashState`**

```dart
sealed class EmptyTrashState { const EmptyTrashState(); }

class EmptyTrashIdle    extends EmptyTrashState { const EmptyTrashIdle(); }
class EmptyTrashLoading extends EmptyTrashState { const EmptyTrashLoading(); }

class EmptyTrashSuccess extends EmptyTrashState {
  final List<EmailId> clearedEmailIds;
  final MailboxId? mailboxId;
  final Role mailboxRole;
  final SubfoldersDeleteStatus subfoldersStatus;
}

class EmptyTrashFailure extends EmptyTrashState {
  final Object? exception;
  final Role mailboxRole;
}

enum SubfoldersDeleteStatus { none, allDeleted, someDeleted, failed }
```

Consumed by `MailboxProviderListenerWidget`. `EmptyTrashSuccess` carries `SubfoldersDeleteStatus` so the UI can show differentiated toasts:

| Status | Toast shown |
|---|---|
| `none` | "Trash emptied" only |
| `allDeleted` | "Trash emptied" + "All subfolders deleted" |
| `someDeleted` | "Trash emptied" + "Some subfolders could not be deleted" |
| `failed` | "Trash emptied" + "Failed to delete subfolders" |

**Private sub-operation results — `_ClearEmailResult` and `_SubfoldersResult`**

These are used only inside `EmptyTrashNotifier.execute()` to model the outcome of each individual step. They are file-private (underscore prefix) and never exported.

```dart
sealed class _ClearEmailResult {}
class _ClearEmailSuccess extends _ClearEmailResult {
  final List<EmailId> emailIds;
  final MailboxId? mailboxId;
}
class _ClearEmailFailure extends _ClearEmailResult {
  final Object? exception;
}

sealed class _SubfoldersResult {}
class _SubfoldersAllDeleted   extends _SubfoldersResult {}
class _SubfoldersSomeDeleted  extends _SubfoldersResult {}
class _SubfoldersDeleteFailed extends _SubfoldersResult {
  final Object? exception;
}
```

The internal switch in `execute()` maps these to `SubfoldersDeleteStatus` with exhaustive coverage:

```dart
subfoldersStatus = switch (subfoldersResult) {
  _SubfoldersAllDeleted()   => SubfoldersDeleteStatus.allDeleted,
  _SubfoldersSomeDeleted()  => SubfoldersDeleteStatus.someDeleted,
  _SubfoldersDeleteFailed() => SubfoldersDeleteStatus.failed,
};
```

If a fourth subtype were added to `_SubfoldersResult`, this switch would be a compile error until handled. The compiler prevents the scenario where a new outcome is added but its effect on the UI is forgotten.

#### Why not just return `bool` or throw an exception from each sub-operation?

```dart
// Tempting but dangerous
Future<bool> _clearMailbox(...) async {
  try { ...; return true; }
  catch (e) { return false; }  // ← the exception is lost
}
```

A `bool` discards the exception; the `EmptyTrashFailure` state can't carry it to the `UrgentExceptionHandler`. Sealed result types carry the exception through the pipeline without exposing it in the public API.

### 3. File-private sealed result types for sub-operations

Covered in detail in [§2 above](#2-sealed-classes--what-they-are-and-why-we-use-them-here). The short form: `_ClearEmailResult` and `_SubfoldersResult` are file-private sealed hierarchies used only inside `execute()`. They carry exceptions through the pipeline without exposing them in the public `EmptyTrashState` API, and the compiler enforces that every variant is handled before the result is translated into a `SubfoldersDeleteStatus`.

### 4. `mounted` guard after every `await`

`@riverpod Notifier` provides `ref.mounted`. The notifier checks `mounted` after each awaited sub-operation before mutating state:

```dart
final emailResult = await _clearMailbox(...);

if (!mounted) return;   // ← guard before writing state

if (emailResult is _ClearEmailFailure) {
  state = EmptyTrashFailure(...);
  return;
}

final subfoldersResult = await _deleteSubfolders(...);

if (!mounted) return;   // ← guard again

state = EmptyTrashSuccess(...);
```

This prevents the `setState called after dispose` class of bugs that would otherwise occur if the user navigates away while the async operation is in flight.

### 5. Skip email clearing when trash is empty

When `trashMailbox.countTotalEmails == 0`, the notifier skips directly to subfolder deletion:

```dart
final emailResult = trashMailbox.countTotalEmails == 0
    ? _ClearEmailSuccess(emailIds: const [], mailboxId: null)
    : useJmapClear
        ? await _clearMailbox(...)
        : await _emptyTrashByEmailDeletion(...);
```

This fixes a regression where empty-trash on a mailbox with no emails but with subfolders would previously exit early with a warning toast and never delete the subfolders.

### 6. `useJmapClear` decision made in the widget, not in the notifier

The decision of whether to use `ClearMailboxInteractor` (JMAP capability) or `EmptyTrashFolderInteractor` (email-by-email) is made in `MailboxProviderListenerWidget._executeEmptyTrash`, not inside `EmptyTrashNotifier`:

```dart
final useJmapClear =
    CapabilityIdentifier.jmapMailboxClear.isSupported(session, accountId) &&
    !trashMailbox.isFirstLevelTeamSystemFolder(
      dashboardController.mapMailboxById,
      PresentationMailbox.trashRole,
    );

ref.read(emptyTrashProvider.notifier).execute(
  session, accountId, trashMailbox, childIds, useJmapClear,
);
```

**Why?** The capability check requires `session` and `accountId` from `MailboxDashBoardController`. Passing a boolean flag to the notifier keeps `EmptyTrashNotifier` free of GetX dependencies. The notifier becomes a pure async orchestrator.

### 7. `MailboxProviderListenerWidget` — bridging back to GetX side effects

The widget uses `ref.listen` (not `ref.watch`) so it reacts to state changes without triggering rebuilds of its `child`:

```dart
class MailboxProviderListenerWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(emptyTrashRequestedProvider, (_, asyncValue) {
      asyncValue.whenData((trashMailbox) => _executeEmptyTrash(...));
    });

    ref.listen(emptyTrashProvider, (_, next) {
      _handleEmptyTrashStateChange(context, next);
    });

    return child;
  }
}
```

`_handleEmptyTrashStateChange` exhaustively pattern-matches on `EmptyTrashState` and calls back into the GetX layer:

- `EmptyTrashLoading` → sets `viewStateMailboxActionProgress` to show the progress bar
- `EmptyTrashSuccess` → resets progress, calls `handleDeleteEmailsInMailbox`, shows toasts, dispatches `RefreshAllMailboxAction`
- `EmptyTrashFailure` → resets progress, shows error toast, delegates to `UrgentExceptionHandler` if the exception is fatal
- `EmptyTrashIdle` → no-op

### 8. `MailboxItemConsumerWidget` — clean widget boundary

`BaseMailboxView.buildMailboxItem` previously inlined `Obx(() => MailboxItemWidget(...))` directly. This is a problem because wrapping the entire mailbox list in `MailboxProviderListenerWidget extends ConsumerWidget` requires a `ConsumerWidget` ancestor — but `BaseMailboxView extends GetWidget<MailboxController>` is not one.

The fix: extract `MailboxItemConsumerWidget extends StatelessWidget` that owns the `Obx` wrapper and wires all callbacks. `BaseMailboxView` now instantiates `MailboxItemConsumerWidget` without any inline lambdas, and `MailboxProviderListenerWidget` wraps the list without hierarchy conflicts.

The `onEmptyMailboxActionCallback` callback now distinguishes Trash from other mailboxes:

```dart
onEmptyMailboxActionCallback: (mailboxNode) {
  if (mailboxNode.item.isTrash) {
    controller.emptyTrashAction(context, mailboxNode.item, controller.mailboxDashBoardController);
  } else {
    controller.emptyMailboxAction(context, mailboxNode.item);
  }
},
```

### 9. `UrgentExceptionHandler` — abstract contract for fatal error handling

A new abstract class extracted to `lib/features/base/urgent_exception_handler.dart`:

```dart
abstract class UrgentExceptionHandler {
  bool validateUrgentException(dynamic exception);
  void handleUrgentException({Failure? failure, Exception? exception});
}
```

`MailboxProviderListenerWidget` retrieves it via `getBinding<UrgentExceptionHandler>()`. This preserves the existing GetX-based error escalation path without `MailboxProviderListenerWidget` needing to know the concrete implementation.

---

## Provider layer structure

Following the architecture freeze in ADR-0092, `empty_trash_provider.dart` lives in the **presentation** layer — it is not a domain or data provider. All providers in this feature are `@riverpod` (auto-dispose) because they are accessed through `ref.listen`/`ref.read` from a `ConsumerWidget` that lives in the widget tree.

```
lib/features/mailbox_dashboard/presentation/providers/
└── empty_trash_provider.dart
    ├── emptyTrashRequestedProvider   (@riverpod, Stream<PresentationMailbox>)
    └── EmptyTrashNotifier            (@riverpod, EmptyTrashState)
```

**Note:** These providers do **not** use `keepAlive: true` — unlike the composer cache providers from ADR-0092, they are consumed by a persistent `ref.listen` in `MailboxProviderListenerWidget`, which keeps them alive for as long as the widget is in the tree.

---

## Unit tests

`EmptyTrashNotifier` is tested in `test/features/mailbox_dashboard/providers/empty_trash_notifier_test.dart` using `ProviderContainer` with `overrideWithValue` for all three interactors:

```dart
container = ProviderContainer(overrides: [
  // Resolve interactors via GetIt/GetX bindings in widget test;
  // in unit tests, inject via GetX.put() mocks
]);
final notifier = container.read(emptyTrashProvider.notifier);
```

Covered scenarios:

| Scenario | Expected final state |
|---|---|
| Empty trash with emails, JMAP clear, no subfolders | `EmptyTrashSuccess(subfoldersStatus: none)` |
| Empty trash with emails, email-deletion path, no subfolders | `EmptyTrashSuccess(subfoldersStatus: none)` |
| Empty trash with no emails but has subfolders | `EmptyTrashSuccess(subfoldersStatus: allDeleted)` |
| Email clearing fails | `EmptyTrashFailure` |
| Email clear succeeds, subfolder deletion partially fails | `EmptyTrashSuccess(subfoldersStatus: someDeleted)` |
| Already executing (guard) | state stays `EmptyTrashLoading`, no double execution |

---

## Consequences

**Positive**

- Subfolder deletion is sequenced deterministically after email clearing; the outcome of each step is fully captured and surfaced to the user via differentiated toasts
- `MailboxDashBoardController` loses one interactor dependency (`EmptyTrashFolderInteractor`) and its entire email-clearing branch — the controller is thinner
- `EmptyTrashNotifier` is independently unit-testable with no GetX binding setup
- The `mounted` guard pattern is now established as a clear convention for all future Riverpod async notifiers in this codebase
- `UrgentExceptionHandler` abstraction decouples the error escalation path from the Riverpod widget layer

**Negative / constraints**

- `emptyTrashRequestedProvider` accesses `Get.find<MailboxDashBoardController>()` — it retains a GetX coupling. This is intentional for the transition period; it will be replaced when `MailboxDashBoardController` itself is migrated to Riverpod
- `MailboxProviderListenerWidget` writes back to `viewStateMailboxActionProgress` (a GetX `Rx`) — this is a deliberate two-way bridge, not a pure Riverpod pattern. It will disappear when the progress bar observation is also migrated
- `MailboxItemConsumerWidget` is an extraction wrapper whose only purpose is to resolve a hierarchy conflict. It becomes unnecessary once `BaseMailboxView` is a `ConsumerWidget` or `ConsumerStatefulWidget`
