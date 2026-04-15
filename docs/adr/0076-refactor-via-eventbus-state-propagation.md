# 0076 - Refactor via AppEventBus + State Providers (OCP-Compliant State Propagation)

## Status
Proposed

## Context

Controllers in TMail historically use the GetX `consumeState(stream, onSuccess: ...)` pattern plus the `EmailActionController` mixin. `consumeState` did three things at once:

1. Execute a stream and dispatch its result into `viewState`.
2. Route the success type via `handleSuccessViewState` — a growing `if/else` chain.
3. Run a controller-local reaction callback (toast, nav).

Consequences:

- `MailboxDashBoardController` and `ThreadController` ballooned past 2K LOC.
- Every new feature (archive, star, move, label, ...) required editing `handleSuccessViewState` in multiple controllers — **OCP violation**.
- Duplicated flag-update logic across controllers.
- Cross-screen state (email list, mailbox map) had no single owner — updates were scattered.

We want to add new email actions **without editing existing controllers** while keeping GetX as the DI / reactive container.

## Decision

Keep GetX as the DI container and introduce three decoupled building blocks on top of it:

### Building Blocks

| Component | Type | Lifecycle | Purpose |
|---|---|---|---|
| `EmailAction` (abstract) | Plain class | Per call | Wraps interactor call + pre/post processing, returns `Stream<Either<Failure, Success>>` |
| `EmailActionQueue` | `GetxService` | App | Central submit point; fires results on bus; manages `CancellationToken` |
| `AppEventBus` | `GetxService` | App | Single pub/sub bus for all domain success/failure events |
| `*StateProvider` (Session / Mailbox / EmailList) | `GetxService` | App | Pure `Rx` state stores mutated only by handlers |
| `*BusHandler` | `GetxService` | App | Subscribes to specific bus events, calls provider mutations |
| `BusHandlerRegistry` | Const map | Compile-time | Central list of handler factories — registering is one entry, cannot be forgotten |

### Flow

```
Controller._action()
  → EmailActionQueue.submit(XEmailAction(...), token: _cancelToken, onSuccess: toastOnly)
    → action.execute(session, accountId) → Stream
      → eventBus.fire(XSuccess | XFailure)
        ├── XBusHandler.on<XSuccess>() → EmailListStateProvider.updateFlag(...)
        │     → Obx(...) rebuilds automatically
        └── onSuccess callback in controller → show toast / navigate (UI only)
```

### Two Channels Replace `consumeState`

- **Channel 1 — Domain state (Bus → Provider → Obx):** always fires, app-lifecycle scoped, survives controller disposal. The only writer of shared email/mailbox state.
- **Channel 2 — UI reactions (`onSuccess` callback):** controller-local toasts, snackbars, navigation. **No state mutations allowed** (enforced by `_show*Toast` naming convention).

### OCP Boundary

Adding a new email action (e.g. Archive):

| Task | Edit | Create |
|---|---|---|
| `ArchiveEmailAction extends EmailAction` | — | new file |
| `ArchiveBusHandler extends GetxService` | — | new file |
| Register in `BusHandlerRegistry` | 1-line entry | — |
| Trigger in calling controller | 1 method | — |
| `EmailListStateProvider` | **none** | — |
| `handleSuccessViewState` | **none** | — |

`handleSuccessViewState` is reduced to controller-lifecycle states only (loading/pagination), not per-action branching.

### Phase Progress

- Phase 1 — `EmailActionQueue` + `AppEventBus` infrastructure — **Done**
- Phase 2 — Split `EmailListStateProvider` into pure store + BusHandlers — **Done**
- Phase 2a — `BusHandlerRegistry` prevents silent registration failure — **Done**
- Phase 2b — Strip state mutations from `onSuccess` (double-update fix) — **Done**
- Phase 3 — Remove email-action branches from `handleSuccessViewState` — Todo
- Phase 4 — Optional `ActionLoadingState`/`ActionDoneState` bus events — Optional

## Consequences

### Positive

- **OCP-compliant** for adding new email actions — zero edits to existing files beyond a 1-line registry entry.
- **Controllers stay thin** — `submit()` + optional toast callback.
- **Single source of truth** for cross-screen state (`EmailListStateProvider`).
- **Background execution** — omit `CancellationToken` and the action survives controller disposal.
- **Incremental migration** — old `consumeState` paths keep working for not-yet-migrated features.
- **No framework swap** — GetX, bindings, routing, tests, team knowledge all retained.
- Low risk per PR — each action migrates independently.

### Negative

- **Two parallel patterns** (old `consumeState` + new queue) until full migration.
- More files per action (Action + BusHandler).
- BusHandler subscriptions must be disposed properly (mitigated by `GetxService` lifecycle).
- Still depends on GetX reactive (`.obs`/`Obx`) — does not solve concerns around GetX's long-term maintenance or global singletons.
- `viewState` as a field lingers for controller-lifecycle loading; mental model is split across two channels.
- Debugging pub/sub events is harder than direct calls — needs disciplined logging.
- Test setup still requires `Get.put(...)` of providers + handlers.

## Alternatives Considered

- **Keep `consumeState` + mixin** — fails OCP, controllers keep growing.
- **Migrate to Riverpod + service architecture** (see ADR 0077) — cleaner long-term boundaries but high effort and framework risk.

## References

- Alternative: `0077-refactor-via-riverpod-service-architecture.md`
