# 92. Upgrade flutter_riverpod to 3.x

Date: 2026-05-28

## Status

Proposed

## Related ADRs

- [ADR-0085](./0085-riverpod-state-management-for-local-settings.md) — introduced `localSettingsNotifierProvider`
- [ADR-0086](./0086-android-composer-draft-loss-on-background.md) — introduced `ComposerAutoSaveNotifier`

## Context

The project uses `flutter_riverpod: ^2.6.1`. Riverpod 3.0 was already stable (released Sep 2025) when `^2.6.1` was introduced in April 2026 — the choice was deliberate, for three reasons:

1. **No UI involvement.** Both pilot features (ADR-0085, ADR-0086) use Riverpod purely for state sharing between GetX controllers via `appProviderContainer.read()/.listen()`. No `ConsumerWidget` or widget-level `ref.watch` was needed. This kept logic changes minimal and avoided restructuring the widget layer alongside the controller layer.

2. **Narrow pilot scope.** ADR-0085's goal was to validate one question: *does GetX + Riverpod coexistence work?* Using the established `StateNotifier` API (well-documented, familiar) kept the pilot's variable count to one. Starting with Riverpod 3.0's `Notifier` API — different lifecycle semantics, `build()` method, `ref` inside the notifier — would have introduced a second unknown simultaneously.

3. **Ecosystem dependency conflicts.** Riverpod 3.0 brings pressure to adopt its tooling (`riverpod_lint`, `riverpod_generator`). Both conflict with this project's `analyzer: ">=12.0.0 <13.0.0"` pin (required by `dart_style` and `json_serializable`). Staying on 2.6.1 avoided forcing a resolution of those conflicts before the pattern was proven.

### Breaking changes in 3.x that affect this codebase

**1. `StateNotifier` / `StateNotifierProvider` moved to `legacy.dart`**

No longer exported from `flutter_riverpod/flutter_riverpod.dart`. Two files extend `StateNotifier` and declare `StateNotifierProvider`; both become compile errors without migration.

**2. `ref.read` inside `Provider` bodies is a lint error**

Riverpod 3.0 enforces `ref.watch` for dependency tracking inside provider factory bodies. `composer_cache_providers.dart` has 6 such call sites.

### Breaking changes in 3.x that do NOT affect this codebase

| Change | Why no impact |
|---|---|
| Automatic retry on async providers | No `FutureProvider` or `StreamProvider` in use |
| Provider pausing when widget goes off-screen | No `ConsumerWidget`; all access is imperative via `appProviderContainer` |
| `ProviderObserver` interface updated | No `ProviderObserver` registered |
| `AutoDispose` type aliases removed | Not used; providers are non-autoDispose or manually invalidated |
| `AsyncValue.value` returns null on error | No `AsyncValue` consumed in current Riverpod code |
| `ProviderException` wraps rethrown errors | No try-catch on provider reads |

### Anti-patterns identified in current usage

**A. Global `ProviderContainer` without `UncontrolledProviderScope`**

`appProviderContainer = ProviderContainer()` is a global singleton with no connection to the Flutter widget tree. The official Riverpod documentation states:

> "If you are using Flutter, you do not need to care about ProviderContainer outside of testing, as it is implicitly created for you by ProviderScope."

This was acknowledged in ADR-0085 as a known limitation. The correct long-term fix is to eliminate `appProviderContainer` entirely and use plain `ProviderScope` at the root. However, this cannot be done in a single step — see *"Why not ProviderScope directly"* below.

**B. `ref.read()` inside `Provider()` factory bodies**

6 call sites in `composer_cache_providers.dart` use `ref.read()` to resolve dependencies inside `Provider(...)` factory bodies. In Riverpod 3.x this is a lint error: `Provider` factories should use `ref.watch()` to correctly track dependency rebuilds.

### Why not `@riverpod` codegen

`riverpod_generator` requires `analyzer <10.0.0`. This project pins `analyzer: ">=12.0.0 <13.0.0"` via `dependency_overrides` for `dart_style` and `json_serializable`. No version overlap exists — codegen remains blocked until upstream resolves the constraint.

## Decision

Upgrade to `flutter_riverpod: ^3.0.0`. This constraint resolves to the latest 3.x stable (currently **3.3.1**) and tracks all future 3.x patch and minor releases automatically. No new packages are added.

### Dependency changes

| Package | Current | Target | Notes |
|---|---|---|---|
| `flutter_riverpod` | `^2.6.1` | `^3.0.0` | Resolves to 3.3.1 (latest 3.x) |
| `riverpod` | transitive | transitive | Resolved automatically |
| `riverpod_lint` | — | — | Not used; can be enabled in a follow-up ADR once tooling conflict resolves |
| `riverpod_generator` | — | — | Blocked by `analyzer` constraint — see above |

### Changes required

#### 1. `main.dart` — add `UncontrolledProviderScope`

Addresses anti-pattern A. Wraps `GetMaterialApp` so the widget tree has access to `appProviderContainer`. GetX controllers continue to use `appProviderContainer.read()/.listen()` unchanged; this addition enables future `ConsumerWidget` migration without a separate architectural step.

```dart
// Before
return GetMaterialApp(...);

// After
return UncontrolledProviderScope(
  container: appProviderContainer,
  child: GetMaterialApp(...),
);
```

**Why `UncontrolledProviderScope` and not plain `ProviderScope`?**

`ProviderScope` creates its own internal `ProviderContainer` that is inaccessible outside the widget tree. The six existing `appProviderContainer` call sites are all **GetX controllers/services** — they have no `BuildContext` or `WidgetRef` and cannot use the widget-tree API:

| File | Operation |
|---|---|
| `LocalSettingsService` | `.read(localSettingsNotifierProvider.notifier).update()` |
| `PreferencesController` | `.read(localSettingsNotifierProvider.notifier).update()` |
| `ThreadController` | `.read(localSettingsNotifierProvider)` + `.listen(...)` |
| `SearchEmailController` | `.read(localSettingsNotifierProvider)` |
| `HandleMobileAutoSaveExtension` | `.read(composerAutoSaveProvider)` + `.invalidate(...)` |
| `HandleComposerRestoreOnMobileExtension` | `.read(resolveComposerCacheForRestoreProvider)` |

If we used plain `ProviderScope`, the result would be **two isolated containers** — one for the widget tree (unused, no `ConsumerWidget` yet) and `appProviderContainer` still required by all six controllers. Both containers would hold separate instances of the same providers with no shared state, which is strictly worse than the current situation.

`UncontrolledProviderScope(container: appProviderContainer)` exposes the **same container** to both the widget tree and the imperative GetX layer — enabling `ConsumerWidget` migration incrementally without a big-bang refactor.

**Eliminating `appProviderContainer` entirely** requires converting each of the six access points from GetX to Riverpod-native code. That is the scope of the GetX → Riverpod migration roadmap (ADR-0077), not this ADR.

**Rule introduced by this ADR: `appProviderContainer` is frozen.** No new `appProviderContainer.read()` / `.listen()` / `.invalidate()` calls may be added. New features that need Riverpod state must use `ConsumerWidget` + `ref.watch/read`. Each ADR-0075 controller migration eliminates one existing call. When all six are gone, `UncontrolledProviderScope` is replaced by plain `ProviderScope` and `appProviderContainer` is deleted.

#### 2. `LocalSettingsNotifier` — `StateNotifier` → `Notifier`

`StateNotifierProvider` → `NotifierProvider`. The `build()` method replaces `super(initialState)`. All call sites (`ref.read`, `.listen`, `.notifier`) are unchanged.

```dart
// Before
class LocalSettingsNotifier extends StateNotifier<PreferencesSetting> {
  LocalSettingsNotifier() : super(PreferencesSetting.initial());
}
final localSettingsNotifierProvider =
    StateNotifierProvider<LocalSettingsNotifier, PreferencesSetting>(
      (ref) => LocalSettingsNotifier());

// After
class LocalSettingsNotifier extends Notifier<PreferencesSetting> {
  @override
  PreferencesSetting build() => PreferencesSetting.initial();
}
final localSettingsNotifierProvider =
    NotifierProvider<LocalSettingsNotifier, PreferencesSetting>(
      LocalSettingsNotifier.new);
```

#### 3. `ComposerAutoSaveNotifier` — `StateNotifierProvider.family` → `NotifierProvider.family`

In Riverpod 3.0, `NotifierProvider.family` passes the family argument through the constructor; `build()` takes no parameters. `StateNotifier.mounted` does not exist on `Notifier` — replaced by a `_mounted` flag via `ref.onDispose`.

Interactors are resolved eagerly in `build()` and stored as `late final` fields. This preserves the existing safety guarantee — async methods (`restore`, `clearCache`) hold plain Dart object references that remain valid even if the provider is disposed mid-flight, avoiding the `StateError` that `ref.read()` inside async methods would throw post-disposal.

```dart
// Before
class ComposerAutoSaveNotifier extends StateNotifier<ComposerAutoSaveState> {
  final ResolveComposerCacheForRestoreInteractor _resolveInteractor;
  final RemoveAllComposerCacheInteractor _removeInteractor;

  ComposerAutoSaveNotifier(this._resolveInteractor, this._removeInteractor)
      : super(const ComposerAutoSaveState());
}
final composerAutoSaveProvider = StateNotifierProvider.family<
    ComposerAutoSaveNotifier, ComposerAutoSaveState, String>(
  (ref, id) => ComposerAutoSaveNotifier(
    ref.read(resolveComposerCacheForRestoreProvider),
    ref.read(removeAllComposerCacheProvider),
  ));

// After
class ComposerAutoSaveNotifier extends Notifier<ComposerAutoSaveState> {
  final String composerId;
  late final ResolveComposerCacheForRestoreInteractor _resolveInteractor;
  late final RemoveAllComposerCacheInteractor _removeInteractor;
  bool _mounted = true;

  ComposerAutoSaveNotifier(this.composerId);

  @override
  ComposerAutoSaveState build() {
    _resolveInteractor = ref.read(resolveComposerCacheForRestoreProvider);
    _removeInteractor = ref.read(removeAllComposerCacheProvider);
    ref.onDispose(() => _mounted = false);
    return const ComposerAutoSaveState();
  }

  bool get mounted => _mounted;
}
final composerAutoSaveProvider = NotifierProvider.family<
    ComposerAutoSaveNotifier, ComposerAutoSaveState, String>(
  (id) => ComposerAutoSaveNotifier(id));
```

#### 4. `composer_cache_providers.dart` — `ref.read` → `ref.watch` inside `Provider` bodies

Addresses anti-pattern B. All 6 `ref.read(...)` calls inside `Provider(...)` factory bodies become `ref.watch(...)`. These providers are non-autoDispose singletons; `watch` adds correct dependency tracking with no behavioral difference at runtime.

#### 5. Unit tests for `ComposerAutoSaveNotifier`

Interactors are no longer injected via constructor — they are resolved in `build()` through `ref`. Tests switch from direct instantiation to `ProviderContainer` with overrides.

```dart
// Before
notifier = ComposerAutoSaveNotifier(mockResolveInteractor, mockRemoveInteractor);

// After
container = ProviderContainer(overrides: [
  resolveComposerCacheForRestoreProvider.overrideWithValue(mockResolveInteractor),
  removeAllComposerCacheProvider.overrideWithValue(mockRemoveInteractor),
]);
notifier = container.read(composerAutoSaveProvider('test-id').notifier);
```

## Consequences

**Positive**
- Eliminates all `StateNotifier` / `StateNotifierProvider` usage; no deprecated API warnings
- `UncontrolledProviderScope` at the root enables future `ConsumerWidget` migration without a separate architectural step
- `riverpod_lint` can be enabled at full strength in a follow-up once the `analyzer` constraint conflict is resolved upstream
- No new runtime dependencies — a version bump and internal code changes only
- Unblocks a future `@riverpod` codegen ADR once `riverpod_generator` supports `analyzer >=12.0.0`

**Negative**
- `ComposerAutoSaveNotifier` owns Android draft-loss prevention (ADR-0086) — manual testing on Android required after migration
- `_mounted` via `ref.onDispose` fires when the provider element is torn down (on `invalidate`), not synchronously — verify stale-write guards in `handle_mobile_auto_save_extension.dart` still hold
