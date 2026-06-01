# 92. Upgrade flutter_riverpod to 3.x

Date: 2026-05-28

## Status

Accepted

## Related ADRs

- [ADR-0085](./0085-riverpod-state-management-for-local-settings.md) — introduced `localSettingsProvider`
- [ADR-0086](./0086-android-composer-draft-loss-on-background.md) — introduced `ComposerAutoSaveNotifier`

## Context

The project uses `flutter_riverpod: ^2.6.1`. Riverpod 3.0 was already stable (released Sep 2025) when `^2.6.1` was introduced in April 2026 — the choice was deliberate, for three reasons:

1. **No UI involvement.** Both pilot features (ADR-0085, ADR-0086) use Riverpod purely for state sharing between GetX controllers via `appProviderContainer.read()/.listen()`. No `ConsumerWidget` or widget-level `ref.watch` was needed.

2. **Narrow pilot scope.** ADR-0085's goal was to validate one question: *does GetX + Riverpod coexistence work?* Using the established `StateNotifier` API kept the pilot's variable count to one.

3. **Ecosystem dependency conflicts.** Riverpod 3.0 brings pressure to adopt its tooling (`riverpod_lint`, `riverpod_generator`). Both conflict with this project's `analyzer: ">=12.0.0 <13.0.0"` pin. Staying on 2.6.1 avoided forcing a resolution before the pattern was proven.

### Breaking changes in 3.x that affect this codebase

**1. `StateNotifier` / `StateNotifierProvider` moved to `legacy.dart`**

No longer exported from `flutter_riverpod/flutter_riverpod.dart`. Two files extend `StateNotifier`; both become compile errors without migration.

**2. `ref.read` inside `Provider` bodies is a lint error**

Riverpod 3.0 enforces `ref.watch` for dependency tracking inside provider factory bodies.

### Anti-patterns identified in current usage

**A. Global `ProviderContainer` without `UncontrolledProviderScope`**

`appProviderContainer = ProviderContainer()` is a global singleton with no connection to the Flutter widget tree. The correct fix is to eliminate it entirely and use plain `ProviderScope`. This cannot be done in one step — see *"Why not ProviderScope directly"* below.

**B. `ref.read()` inside `Provider()` factory bodies**

6 call sites in `composer_cache_providers.dart` used `ref.read()` to resolve dependencies inside `Provider(...)` factory bodies.

## Decision

Upgrade to `flutter_riverpod: ^3.3.1` and adopt `@riverpod` codegen across the entire composer cache provider chain.

### Dependency changes

| Package | Previous | Resolved | Type | Notes |
|---|---|---|---|---|
| `flutter_riverpod` | `^2.6.1` | `3.3.1` | direct | Tracks all future 3.x patch/minor |
| `riverpod` | transitive | `3.3.1` | transitive | Resolved automatically |
| `riverpod_annotation` | — | `4.0.2` | direct (runtime) | Annotation types only |
| `riverpod_generator` | — | `4.0.4-dev.3` | dev | Build-time only; prerelease with `analyzer ^12.0.0` support |
| `freezed_annotation` | transitive `^2.4.4` | `3.1.0` | override | `riverpod_generator` requires `^3.0.0`; `super_dns_client` pins `^2.4.4`; annotation-only so overriding is safe |

### `keepAlive: true` rule

Riverpod 3.x defaults to `autoDispose: true` — providers are disposed when they have no active listeners. All providers in this codebase use `@Riverpod(keepAlive: true)` because every access is imperative (`appProviderContainer.read()/.listen()`) from GetX controllers with no persistent `ref.watch()` listener. Without `keepAlive`, a `.read()` call with no watcher causes the provider to be disposed immediately, destroying state and recreating instances on every call.

This rule applies until the corresponding GetX controller is migrated to `ConsumerWidget`. Once a provider has a persistent `ref.watch()` from the widget tree, `keepAlive` can be dropped on a case-by-case basis.

## Changes made in this ADR

### 1. `main.dart` — add `UncontrolledProviderScope`

Wraps `GetMaterialApp` so the widget tree shares `appProviderContainer`. GetX controllers continue to use `appProviderContainer.read()/.listen()` unchanged; this enables future `ConsumerWidget` migration without a separate architectural step.

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

`ProviderScope` creates its own internal `ProviderContainer` that is inaccessible outside the widget tree. The six existing `appProviderContainer` call sites are all GetX controllers/services with no `BuildContext` or `WidgetRef`. Using plain `ProviderScope` would create **two isolated containers** — one for the widget tree (unused) and `appProviderContainer` still required by all six controllers. Both would hold separate instances of the same providers with no shared state.

`UncontrolledProviderScope(container: appProviderContainer)` exposes the **same container** to both the widget tree and the imperative GetX layer, enabling incremental `ConsumerWidget` migration.

### 2. `LocalSettingsNotifier` — `StateNotifier` → `@riverpod Notifier`

```dart
// Before
class LocalSettingsNotifier extends StateNotifier<PreferencesSetting> {
  LocalSettingsNotifier() : super(PreferencesSetting.initial());
  void update(PreferencesSetting settings) => state = settings;
}
final localSettingsProvider =
    StateNotifierProvider<LocalSettingsNotifier, PreferencesSetting>(
      (ref) => LocalSettingsNotifier());

// After — local_settings_notifier.dart
part 'local_settings_notifier.g.dart';

@Riverpod(keepAlive: true)
class LocalSettingsNotifier extends _$LocalSettingsNotifier {
  @override
  PreferencesSetting build() => PreferencesSetting.initial();

  void update(PreferencesSetting settings) => state = settings;
}
// localSettingsProvider generated by build_runner
```

Call sites (`LocalSettingsService`, `PreferencesController`, `ThreadController`, `SearchEmailController`) are unchanged — the generated provider name is identical.

### 3. `ComposerAutoSaveNotifier` — `StateNotifierProvider.family` → `@riverpod Notifier` family

With `@riverpod` codegen, the family argument becomes a parameter of `build()` directly. `StateNotifier.mounted` does not exist on `Notifier` — replaced by a `_mounted` flag via `ref.onDispose`.

Interactors are resolved eagerly in `build()` via `ref.read()` and stored as `late final` fields. This preserves the safety guarantee — async methods hold plain Dart object references that remain valid even if the provider is disposed mid-flight.

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

// After — composer_auto_save_notifier.dart
part 'composer_auto_save_notifier.g.dart';

@Riverpod(keepAlive: true)
class ComposerAutoSaveNotifier extends _$ComposerAutoSaveNotifier {
  bool _mounted = true;
  late final ResolveComposerCacheForRestoreInteractor _resolveInteractor;
  late final RemoveAllComposerCacheInteractor _removeInteractor;

  @override
  ComposerAutoSaveState build(String composerId) {
    _resolveInteractor = ref.read(resolveComposerCacheForRestoreProvider);
    _removeInteractor = ref.read(removeAllComposerCacheProvider);
    ref.onDispose(() => _mounted = false);
    return const ComposerAutoSaveState();
  }

  bool get mounted => _mounted;
}
// composerAutoSaveProvider(String composerId) generated by build_runner — name unchanged
```

`ComposerAutoSaveNotifier` is a family provider: each `composerId` creates a separate instance. Instances must be explicitly cleaned up when the composer closes to prevent unbounded growth. Call sites in `handle_mobile_auto_save_extension.dart` require no change.

### 4. `composer_cache_providers.dart` — deleted; providers moved inline with `@riverpod` codegen

The file contained 6 `Provider(ref => ...)` factories using `ref.read()`. Rather than patching `ref.read` → `ref.watch` in-place, each provider was relocated to the file that owns the class, adopting `@riverpod` codegen throughout.

The full provider chain after migration:

| File | Provider | Depends on |
|---|---|---|
| `composer_hive_cache_client.dart` | `composerHiveCacheClientProvider` | — |
| `cache_exception_thrower.dart` | `cacheExceptionThrowerProvider` | — |
| `composer_persistent_cache_datasource_impl.dart` | `composerCacheDatasourceProvider` | `composerHiveCacheClientProvider`, `cacheExceptionThrowerProvider` |
| `composer_cache_repository_impl.dart` | `composerCacheRepositoryProvider` | `composerCacheDatasourceProvider` |
| `resolve_composer_cache_for_restore_interactor.dart` | `resolveComposerCacheForRestoreProvider` | `composerCacheRepositoryProvider` |
| `remove_all_composer_cache_interactor.dart` | `removeAllComposerCacheProvider` | `composerCacheRepositoryProvider` |
| `mark_composer_cache_clean_close_interactor.dart` | `markComposerLocalCacheCleanCloseProvider` | `composerCacheRepositoryProvider` |

All dependencies use `ref.watch()` — correct dependency tracking with no behavioral difference at runtime since all providers are `keepAlive` singletons.

### 5. Unit tests for `ComposerAutoSaveNotifier`

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

## What remains

### Frozen rule: no new `appProviderContainer` call sites

`appProviderContainer` is frozen. No new `.read()` / `.listen()` / `.invalidate()` calls may be added to it. New features that need Riverpod state must use `ConsumerWidget` + `ref.watch/read` against the widget tree scope.

### Six existing call sites to migrate

| File | Operation | Migration target |
|---|---|---|
| `LocalSettingsService` | `.read(localSettingsProvider.notifier).update()` | Inject via `ConsumerWidget` or `ref` in a Riverpod-native service |
| `PreferencesController` | `.read(localSettingsProvider.notifier).update()` | Migrate controller to `Notifier` or `ConsumerWidget` |
| `ThreadController` | `.read(localSettingsProvider)` + `.listen(...)` | Migrate to `ConsumerWidget` + `ref.watch` |
| `SearchEmailController` | `.read(localSettingsProvider)` | Migrate to `ConsumerWidget` + `ref.watch` |
| `HandleMobileAutoSaveExtension` | `.read(composerAutoSaveProvider(id).notifier)` + `.invalidate(...)` | Migrate composer to `ConsumerStatefulWidget` |
| `HandleComposerRestoreOnMobileExtension` | `.read(resolveComposerCacheForRestoreProvider)` | Migrate to `ref.read` within a `ConsumerWidget` |

Each migration will be covered by a dedicated ADR and eliminates one `appProviderContainer` call site. When all six are gone:

1. Replace `UncontrolledProviderScope` with plain `ProviderScope` in `main.dart`
2. Delete `appProviderContainer` from `app_provider_container.dart`
3. Enable `riverpod_lint` (follow-up ADR)

## Consequences

**Positive**
- Eliminates all `StateNotifier` / `StateNotifierProvider` usage; no deprecated API warnings
- `@riverpod` codegen adopted across the entire composer cache stack — provider boilerplate is generated, not hand-written
- `UncontrolledProviderScope` at root enables future `ConsumerWidget` migration without a separate architectural step
- Provider dependency chain uses `ref.watch()` — correct rebuild semantics
- `riverpod_lint` can be enabled in a follow-up ADR once `appProviderContainer` is removed

**Negative**
- All providers use `keepAlive: true` — they live for the entire app lifetime, no automatic cleanup. This is intentional and matches the current GetX singleton pattern, but becomes unnecessary once controllers are fully migrated to `ConsumerWidget`
- `ComposerAutoSaveNotifier` (family) requires explicit `invalidate()` on composer close to prevent unbounded instance accumulation — missing invalidation is a silent memory leak
- `ComposerAutoSaveNotifier` owns Android draft-loss prevention (ADR-0086) — manual testing on Android required after this migration
