# 93. Urgent-exception handling for Riverpod flows

Date: 2026-06-29

## Status

Accepted

## Related ADRs

- [ADR-0085](./0085-riverpod-state-management-for-local-settings.md) — GetX + Riverpod coexistence
- [ADR-0092](./0092-upgrade-flutter-riverpod-3.md) — `appProviderContainer` frozen; migrate to `ConsumerWidget`

## Context

GetX controllers consume interactors through `BaseController.consumeState`, whose `onData` / `onError` run `validateUrgentException(...)` → `handleUrgentException(...)`.
That routing drives re-login / save-and-reconnect / connection-error UX for `NoNetworkError`, `BadCredentialsException`, `ConnectionError`, `RefreshTokenFailedException`.
Riverpod notifiers consume interactors directly (`interactor.execute(...).last`), bypassing `consumeState`. They therefore lose this routing: a dismiss that fails on an expired token would show a generic toast instead of triggering a re-login. The `empty_folder` delegate had already re-implemented a partial version of this inline, handling only a bare exception (not a `Left(FeatureFailure)`).

## Decision

Add one shared primitive, `handleUrgentExceptionIfNeeded({Failure? failure, Object? exception})` (`lib/features/base/handle_urgent_exception.dart`). It resolves the registered `UrgentExceptionHandler` via the `getBinding` bridge, unwraps both carriers exactly like `BaseController` (`FeatureFailure.exception` or a bare exception), routes urgent  exceptions to `handleUrgentException`, and returns `true` when it handled one.

**Rule:** any Riverpod flow consuming an interactor result MUST call this on failure. The caller skips its own failure UI when it returns `true`. `TwpWarningDismiss` adopts it (reporting `TwpWarningDismissResult.urgentHandled`); the `empty_folder` delegate is refactored onto it, removing the duplicated inline logic.

### Handler is a lifetime service, not a screen controller

The `UrgentExceptionHandler` slot was bound to `MailboxDashBoardController` (`Get.put<UrgentExceptionHandler>(Get.find<MailboxDashBoardController>())`). That controller is absent on a web reload onto a non-dashboard route (e.g. Settings, where `MailboxDashBoardBindings` does not run — cf. ADR-0085), so `getBinding` would return `null` and urgent exceptions on those screens would be silently dropped.
Bind the slot instead to `UrgentExceptionHandlerService` — a dedicated `BaseController` subclass registered `lazyPut(fenix: true)` in `MainBindings` (which runs at every bootstrap, before `runApp`). It reuses the proven `BaseController` routing unchanged and exists for the app lifetime regardless of the mounted screen. The dashboard keeps its own `handleUrgentExceptionOnMobile` override for its own `consumeState` path (that calls `this.handleUrgentException`, not the registered slot).

## Consequences

**Positive**
- Re-login / reconnect handling is no longer silently dropped in Riverpod flows.
- Single source of truth; future Riverpod implementers call one documented function.
- No new `appProviderContainer` call site (ADR-0092 compliant).
- Urgent handling works on every route, including direct web reloads onto Settings or other non-dashboard screens.

**Negative**
- Still depends on `getBinding<UrgentExceptionHandler>()` — the GetX bridge. When the handler is exposed as a Riverpod provider, `handle_urgent_exception.dart` and `UrgentExceptionHandlerService` are the only places to change.
- The contract is a convention, not enforced by the type system; reviewers must check new Riverpod failure paths call it.
- `UrgentExceptionHandlerService` subclasses `BaseController` to reuse its routing; the cleaner end-state is to extract the routing into a framework-free service / Riverpod provider once GetX is removed.
