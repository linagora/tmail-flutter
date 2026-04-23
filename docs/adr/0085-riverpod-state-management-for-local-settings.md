# 85. Riverpod State Management Pilot — Local Settings & Collapsed Thread in Search

Date: 2026-04-23

## Status

Accepted

## Related ADRs

- [ADR-0071](./0071-collapse-threads-in-email-query.md) — collapseThreads in Email/query

## Context

As part of implementing the collapsed thread feature in search email (TF-4363), two controllers need to read the `collapseThreads` local setting:

- `ThreadController` — must react when the setting changes to re-trigger search
- `SearchEmailController` — must read the current value at query time

The setting is written by `PreferencesController` via `UpdateLocalSettingsInteractor` when the user toggles it in `PreferencesView`.

Rather than routing this through a GetX-based `LocalSettingsService` with a reactive `Rx` field and `ever(...)` listeners — which would require manual equality tracking and expose mutable state broadly — we chose to use Riverpod's `StateNotifier` as the single source of truth from the start.

This is also a **pilot** to validate the GetX + Riverpod coexistence pattern before applying it more broadly across the codebase.

## Decision

Introduce `localSettingsNotifierProvider` (`StateNotifier<PreferencesSetting>`) backed by a global `ProviderContainer` (`appProviderContainer`). All reads and writes go through this provider directly.

### Architecture

```text
┌──────────────────────────────────────────────────────────┐
│  appProviderContainer  (global ProviderContainer)        │
│                                                          │
│   localSettingsNotifierProvider                          │
│   StateNotifier<PreferencesSetting>                      │
│       ▲ write              ▲ write        read ▼         │
│       │                    │                  │          │
│  LocalSettingsService  PreferencesController  Thread /   │
│  (app start /          (on toggle)            Search     │
│   route reload)                               Controllers│
└──────────────────────────────────────────────────────────┘
```

### Write paths

**On app start / settings route reload:**
`LocalSettingsService.onInit()` → `_loadInitialSettings()` → cache read → `localSettingsNotifierProvider.notifier.update()`

**On user toggle in PreferencesView:**
`PreferencesController.handleSuccessViewState(UpdateLocalSettingsSuccess)` → `localSettingsNotifierProvider.notifier.update()`

### Read paths

**`ThreadController`** — subscribes via `appProviderContainer.listen(localSettingsNotifierProvider, ...)`. Riverpod skips notification when `PreferencesSetting` equality is unchanged (`EquatableMixin`), so no manual dedup is needed.

**`SearchEmailController`** — reads on demand via `appProviderContainer.read(localSettingsNotifierProvider)`.

### `LocalSettingsService` role

`LocalSettingsService` is a `GetxService` acting as a **temporary bridge** between the GetX DI graph and Riverpod. It remains a `GetxService` because all DI wiring in the project uses GetX bindings — introducing a plain class would be inconsistent with the existing layer. Its sole responsibility is loading the initial value from cache into the provider on startup via `onInit`.

It will be removed entirely once `ManageAccountRepository` and its datasources are migrated to Riverpod providers, at which point `LocalSettingsNotifier` can inject and call `GetLocalSettingsInteractor` directly.

### Settings route reload on web

When the user reloads the browser directly on the settings route, `MailboxDashBoardBindings` does not run. `ManageAccountDashBoardBindings` guards against this:

```dart
if (!Get.isRegistered<LocalSettingsService>()) {
  Get.put(LocalSettingsService(Get.find<GetLocalSettingsInteractor>()));
}
```

## Consequences

**Positive**
- No redundant cache round-trip — provider is updated directly from `UpdateLocalSettingsSuccess` result
- No manual equality tracking needed — Riverpod + `EquatableMixin` handles it
- Single write surface for `PreferencesSetting`; no mutable `Rx` exposed across the codebase
- Validates the GetX + Riverpod coexistence pattern for future migrations

**Negative**
- `appProviderContainer` is a global singleton — controllers depend directly on a concrete implementation rather than an abstraction, which is a known DIP violation. The correct solution is to wrap it behind an interface (e.g. `LocalSettingsRepository`), but doing so now would add complexity before the pattern is proven at scale. This should be addressed when the migration reaches the repository layer.
- Two DI systems (GetX + Riverpod) coexist during the migration period; developers must know which layer owns which state
- `LocalSettingsService` is a temporary class that must be removed when the migration reaches the repository layer
