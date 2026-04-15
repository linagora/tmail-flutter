# 0077 - Refactor via Riverpod + Service Architecture

## Status
Proposed

## Context

The TMail presentation layer is built on GetX: 53 `GetxController` subclasses, 72 `Bindings`, heavy use of `.obs`/`Obx`, `Get.find`, `Get.context`, and `GetMaterialApp` routing. Several controllers exceed 2K LOC and mix:

- Interactor orchestration
- Shared state (email list, mailbox map, session)
- Controller-lifecycle state (loading, paging, errors)
- UI reactions (toast, navigation, dialogs)
- Cross-controller coordination via `Get.find<OtherController>()`

Pain points:

- God-controllers are hard to test — setup requires spinning up DI graphs, bindings, and mocking `Get.context`.
- Cross-controller `Get.find` creates implicit, untyped dependencies.
- Integration tests are tied to GetX lifecycle (robots use `Get.put`).
- Async disposal + `Get.context` are fragile in isolates (FCM, WebSocket).
- GetX maintenance trajectory and ecosystem momentum are weakening versus Riverpod.

We want compile-time-checked DI, explicit dependency graphs, and testable services — without touching the domain layer (interactors, JMAP client, Hive cache).

## Decision

Migrate the presentation layer off GetX and onto **Riverpod + Service architecture**, decomposing 53 controllers into focused services and state notifiers.

### Layering

```
Widget (ConsumerWidget)
  ├─ ref.watch(stateNotifier)             reactive display
  ├─ ref.read(service.notifier).method()  trigger
  └─ ref.listen(stateNotifier, cb)        UI side effects

Service (@Riverpod keepAlive)
  ├─ Orchestrates interactors
  ├─ Mutates state notifiers
  └─ Triggers toast / navigation

StateNotifier (@Riverpod keepAlive | autoDispose)
  └─ Pure observable store + mutation methods

Interactor (unchanged)   → Either<Failure, Success>

Data Layer (unchanged)   → Dio, Hive, JMAP client
```

### Service Decomposition (11 services)

`EmailFlagService`, `EmailOrganizationService`, `EmailComposeService`, `EmailSearchService`, `MailboxService`, `AttachmentService`, `AuthService`, `SyncService`, `IdentityService`, `SettingsService`, `NotificationService` — see migration plan for LOC estimates.

### State Notifier Inventory

`SessionNotifier`, `CurrentAccountNotifier`, `EmailListNotifier`, `MailboxListNotifier`, `ThreadDetailNotifier` (autoDispose), `ComposerDraftNotifier` (autoDispose), `SearchStateNotifier` (autoDispose), `SelectionNotifier` (autoDispose), `UnreadCountNotifier` (derived).

### Coexistence Strategy

- Install Riverpod alongside GetX — do **not** remove GetX until final phase.
- New services are registered in Riverpod from day one.
- `RiverpodBridge.read(p)` adapter allows old GetX controllers to read Riverpod state during migration.
- Screen-by-screen migration — one PR = one screen's widget + controller → widget + service.

### Phase Plan (16 phases, ~77 days)

Foundation → infra providers → state notifiers → routing (`go_router`) → auth → email flags/organization → sync → compose → search → mailbox → attachments → settings → notifications → widget migration → tests → GetX removal.

### Routing

Replace `GetMaterialApp` with `go_router` (or `auto_route` — open question). Must preserve deferred-loading on web.

### Success Criteria

- Zero `package:get` imports in `lib/` after final phase.
- All 53 controllers removed or converted.
- All 72 Bindings deleted.
- Widget tests use `ProviderContainer`, no `Get.put`.
- Cold-start regression < 10%.
- No P1/P2 bug uptick over 1 month post-migration.

## Consequences

### Positive

- **Compile-time DI graph** — no runtime `Get.find` surprises; unused providers flagged.
- **Explicit dependencies** via `ref.watch` / `ref.read` — easier to reason about and refactor.
- **Testability** — `ProviderContainer.test()` with `overrideWith` per test; no global DI setup.
- **Service/Notifier split** enforces separation between orchestration and state — harder to regrow god-objects.
- **AsyncValue** gives a unified loading/error/data state shape, replacing ad hoc `viewState` patterns.
- **Isolate-safe** container access pattern for FCM / WebSocket.
- **Aligned with modern Flutter community** — long-term maintenance and hiring.
- `go_router` declarative routing enables deep linking and web URL sync properly.

### Negative

- **High effort** — ~77 engineer-days across 16 phases.
- **High risk** — two DI systems coexist during months of migration; partial states possible on main.
- **Routing migration is invasive** — deferred loading, 15+ routes, web/mobile parity all at once.
- **Test suite rewrite** — all widget and integration tests must move off `Get.put` / robots.
- **Team learning curve** — Riverpod generator, code-gen workflow, `ref` lifecycle rules.
- **Feature-delivery slowdown** during routing and auth phases (2-3 week partial freeze likely).
- **Code-gen dependency** if we adopt `riverpod_generator` — build times, CI friction.
- Risk of inconsistent patterns if phases stall mid-flight — partial migration is the worst state.

### UI Update Model

- **Reactive reads:** `ref.watch(provider)` inside `ConsumerWidget.build` — rebuilds only the consuming widget. Finer-grained than `Obx` via `select`:
  ```dart
  final unread = ref.watch(emailListNotifierProvider.select((s) => s.unreadCount));
  ```
  Only rebuilds when the selected slice changes, not the whole list.
- **Side effects (toast, nav, dialog):** `ref.listen(provider, (prev, next) { ... })` inside `build` — runs callbacks without subscribing the widget to rebuild.
- **Imperative triggers:** `ref.read(service.notifier).method()` from button callbacks — no subscription.
- **Unified loading/error:** `AsyncValue<T>.when(data:, loading:, error:)` replaces `viewState` + ad hoc `Obx` patterns.
- **Rebuild cost** is equal-or-better than GetX — `select` is first-class, no manual `GetBuilder` ids needed.

### Global Shared State

Session, current account, mailbox map, email list, etc. remain global — Riverpod models this explicitly:

- Annotate with `@Riverpod(keepAlive: true)` (or non-autoDispose providers) — live for app lifetime, same role as `GetxService`.
- **Non-widget access:** a single top-level `ProviderContainer` (`appContainer`) allows `appContainer.read(sessionNotifierProvider)` from interactors, FCM isolate, WebSocket push handlers — same reach as `Get.find`, but typed and compile-checked.
- **Cross-feature reads:** feature A's service does `ref.watch(sessionNotifierProvider)` and `ref.read(mailboxListNotifierProvider.notifier).addMailbox(...)` — explicit, no `Get.find<T>()` string-keyed lookup, auto-refactorable.
- **Derived state:** `UnreadCountNotifier` simply `ref.watch`es `EmailListNotifier` — auto-recompute, no manual wiring.
- **Isolate safety:** pass `ProviderContainer` into isolate bootstrap or use the `appContainer` singleton — explicit, testable. Solves the `Get.context`/`Get.find` fragility in FCM and WebSocket isolates.
- **`RiverpodBridge.read(p)`** — during migration, old GetX controllers read the same global state via the shared container; no duplicated stores.

### Runtime Plug-and-Play

Providers are declared at compile time; their **content** is decided at runtime by `ref.watch`ing reactive config/tier state. Consumers watch the slot, never the config.

```dart
@Riverpod(keepAlive: true)
CloudPicker? drivePicker(Ref ref) {
  final cfg = ref.watch(remoteConfigProvider);
  return cfg.driveEnabled ? GoogleDrivePicker(cfg.driveApiKey) : null;
}
```

- Remote config toggle / per-tier gating → feature provider re-evaluates, widgets rebuild, no restart.
- Registry aggregates nullable feature providers via `whereType<X>()` for N-of-many plug-ins.
- `.family` for per-key instances; `overrideWith` for flavor / tenant / A-B swaps.

No runtime `Get.put`/`Get.delete` — gates are greppable and unit-testable (`overrideWith(true|false)`).

- **Stay on GetX + ADR 0076 (EventBus + State Providers)** — far cheaper, OCP-friendly for actions, but keeps GetX's weaknesses and ties long-term to a slowing ecosystem.
- **Rewrite presentation layer from scratch** — rejected; unacceptable risk and cost.
- **Partial migration (services only, keep GetX routing/widgets)** — deferred as a fallback if full migration stalls.

## References

- Alternative: `0076-refactor-via-eventbus-state-propagation.md`
