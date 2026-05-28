# 92. Upgrade flutter_riverpod to 3.0 — eliminate StateNotifier, fix Provider body reads

Date: 2026-05-28

## Status

Accepted

## Related ADRs

- [ADR-0085](./0085-riverpod-state-management-for-local-settings.md) — introduced `localSettingsNotifierProvider`
- [ADR-0086](./0086-android-composer-draft-loss-on-background.md) — introduced `ComposerAutoSaveNotifier` (composer draft-loss prevention on Android)

## Context

The project uses `flutter_riverpod: ^2.6.1`. Riverpod 3.0 removes `StateNotifier` and `StateNotifierProvider` from the public API of `flutter_riverpod` (they remain only in the `riverpod` legacy export, which is not imported by this codebase).

Scanning `lib/` reveals two compile-time breaks and two additional lint violations on 3.0:

### Removed APIs — compile errors

| File | Current | Breaks on 3.0 |
|------|---------|----------------|
| `lib/features/manage_account/presentation/providers/local_settings_notifier.dart` | `extends StateNotifier<PreferencesSetting>`, `StateNotifierProvider` | `StateNotifier` not exported |
| `lib/features/composer/presentation/providers/composer_auto_save_notifier.dart` | `extends StateNotifier<ComposerAutoSaveState>`, `StateNotifierProvider.family` | `StateNotifier` not exported |

### `ref.read` inside `Provider` bodies — lint error under `riverpod_lint`

`composer_cache_providers.dart` lines 20, 21, 26, 30, 34, 38 all call `ref.read(...)` inside `Provider(...)` factory bodies. Riverpod 3.0 enforces `ref.watch` for dependency tracking inside provider bodies.

### `notifier.mounted` — no such getter on `Notifier`

`handle_mobile_auto_save_extension.dart` lines 166 and 185 access `notifier.mounted`, which exists on `StateNotifier` but not on `Notifier`. Requires explicit lifecycle tracking.

### Why not `@riverpod` codegen

`riverpod_generator` (all 3.x and 4.x versions) requires `analyzer <10.0.0`. The project pins `analyzer: ">=12.0.0 <13.0.0"` in `dependency_overrides` to support `dart_style 3.1.8` and `json_serializable 6.10+` null-aware element generation. These constraints have no overlap — codegen is blocked until `riverpod_generator` supports `analyzer >=12.0.0`.

### No external dependency conflicts

No third-party package in `pubspec.lock` (`linagora_design_flutter`, `jmap_dart_client`, or any of the 11 sub-packages) declares a `riverpod` dependency. The upgrade is purely internal.

---

## Decision

Upgrade `flutter_riverpod: ^2.6.1` → `^3.0.0` (resolves to 3.3.1) using the manual `Notifier` API. Four commits:

### Commit 1 — Bump dependency

```yaml
# pubspec.yaml
dependencies:
  flutter_riverpod: ^3.0.0   # was ^2.6.1
```

Run `flutter pub get`. No other packages change.

---

### Commit 2 — Migrate `LocalSettingsNotifier`

**File:** `lib/features/manage_account/presentation/providers/local_settings_notifier.dart`

```dart
// Before
class LocalSettingsNotifier extends StateNotifier<PreferencesSetting> {
  LocalSettingsNotifier() : super(PreferencesSetting.initial());
  void update(PreferencesSetting settings) { state = settings; }
}
final localSettingsNotifierProvider =
    StateNotifierProvider<LocalSettingsNotifier, PreferencesSetting>(
  (ref) => LocalSettingsNotifier());

// After
class LocalSettingsNotifier extends Notifier<PreferencesSetting> {
  @override
  PreferencesSetting build() => PreferencesSetting.initial();
  void update(PreferencesSetting settings) { state = settings; }
}
final localSettingsNotifierProvider =
    NotifierProvider<LocalSettingsNotifier, PreferencesSetting>(
  LocalSettingsNotifier.new);
```

`NotifierProvider` (non-autoDispose) is the direct equivalent of `StateNotifierProvider` for a keepAlive singleton. All call sites — `appProviderContainer.read(localSettingsNotifierProvider)`, `.listen(...)`, `.notifier.update(...)` — remain unchanged.

---

### Commit 3 — Migrate `ComposerAutoSaveNotifier`

**File:** `lib/features/composer/presentation/providers/composer_auto_save_notifier.dart`

In Riverpod 3.0, `NotifierProvider.family` passes the family argument to the notifier constructor (`NotifierT Function(ArgT arg) create`). The `build()` method takes no arguments.

```dart
// Before
class ComposerAutoSaveNotifier extends StateNotifier<ComposerAutoSaveState> {
  final ResolveComposerCacheForRestoreInteractor _resolveInteractor;
  final RemoveAllComposerCacheInteractor _removeInteractor;

  ComposerAutoSaveNotifier(this._resolveInteractor, this._removeInteractor)
      : super(const ComposerAutoSaveState());
  // methods call _resolveInteractor / _removeInteractor directly
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
  bool _mounted = true;

  ComposerAutoSaveNotifier(this.composerId);

  @override
  ComposerAutoSaveState build() {
    ref.onDispose(() => _mounted = false);
    return const ComposerAutoSaveState();
  }

  bool get mounted => _mounted;

  // methods call ref.read(resolveComposerCacheForRestoreProvider) etc.
}
final composerAutoSaveProvider = NotifierProvider.family<
    ComposerAutoSaveNotifier, ComposerAutoSaveState, String>(
  (id) => ComposerAutoSaveNotifier(id));
```

Consumer call sites in `handle_mobile_auto_save_extension.dart` and `handle_composer_restore_on_mobile_extension.dart` remain unchanged:
- `appProviderContainer.read(composerAutoSaveProvider(id).notifier)` ✓
- `appProviderContainer.invalidate(composerAutoSaveProvider(id))` ✓
- `notifier.mounted` ✓ (via custom `_mounted` getter)

---

### Commit 4 — Fix `ref.read` → `ref.watch` in `composer_cache_providers.dart`

Replace all 6 `ref.read(...)` calls inside `Provider(...)` factory bodies with `ref.watch(...)`.

| Line | Current | After |
|------|---------|-------|
| 20 | `ref.read(_composerHiveCacheClientProvider)` | `ref.watch(_composerHiveCacheClientProvider)` |
| 21 | `ref.read(_cacheExceptionThrowerProvider)` | `ref.watch(_cacheExceptionThrowerProvider)` |
| 26 | `ref.read(_composerHiveCacheClientProvider)` | `ref.watch(_composerHiveCacheClientProvider)` |
| 26 | `ref.read(_cacheExceptionThrowerProvider)` | `ref.watch(_cacheExceptionThrowerProvider)` |
| 30 | `ref.read(composerCacheRepositoryProvider)` | `ref.watch(composerCacheRepositoryProvider)` |
| 34 | `ref.read(composerCacheRepositoryProvider)` | `ref.watch(composerCacheRepositoryProvider)` |
| 38 | `ref.read(composerCacheRepositoryProvider)` | `ref.watch(composerCacheRepositoryProvider)` |

These are plain `Provider<T>` singletons with no auto-dispose. Switching to `watch` adds proper dependency tracking without behavioral change.

---

### Commit 5 — Update `ComposerAutoSaveNotifier` unit test

**File:** `test/features/composer/presentation/providers/composer_auto_save_notifier_test.dart`

Direct constructor instantiation `ComposerAutoSaveNotifier(interactor1, interactor2)` no longer works because interactors are now resolved through `ref` inside the notifier. Replace with `ProviderContainer` + provider overrides:

```dart
// Before
setUp(() {
  notifier = ComposerAutoSaveNotifier(mockResolveInteractor, mockRemoveInteractor);
});

// After
late ProviderContainer container;
late ComposerAutoSaveNotifier notifier;

setUp(() {
  container = ProviderContainer(overrides: [
    resolveComposerCacheForRestoreProvider
        .overrideWithValue(mockResolveInteractor),
    removeAllComposerCacheProvider
        .overrideWithValue(mockRemoveInteractor),
  ]);
  notifier = container.read(composerAutoSaveProvider('test-id').notifier);
});

tearDown(() => container.dispose());
```

Test cases themselves remain unchanged — the notifier public API (`restore`, `clearCache`, `onSnapshotSaved`, etc.) is identical.

---

## Risks

### Risk 1 — `_mounted` timing vs `StateNotifier.mounted`

`StateNotifier.mounted` becomes `false` synchronously inside `dispose()`. The `ref.onDispose` callback fires at the same point in the Riverpod lifecycle (when the provider element is torn down, triggered by `container.invalidate`). Semantics are equivalent, but the callback is asynchronous relative to `invalidate()`. The guards at lines 166 and 185 of `handle_mobile_auto_save_extension.dart` prevent writes to a disposed notifier — verify they still prevent stale writes after migration.

### Risk 2 — `ref.watch` in `composer_cache_providers.dart` changes provider lifecycle

Switching from `read` to `watch` inside `Provider` bodies means each provider now subscribes to its dependencies. These are non-autoDispose providers in a long-lived `ProviderContainer` (`appProviderContainer`). No dispose risk, but if any dependency provider is ever replaced via `override` in tests, the watchers will be notified. Audit test setups that override these providers.

### Risk 3 — `ComposerAutoSaveNotifier` interactor access via `ref`

Previously, interactors were injected at construction time and available immediately. After migration, `ref.read(resolveComposerCacheForRestoreProvider)` is called at method invocation time. If the provider is accessed after `container.invalidate()` (i.e., after `tearDownMobileAutoSave()`), it will throw a `ProviderNotFoundException`. The `_mounted` guard prevents this, but verify the guard is checked before every `ref.read` call in async methods.

---

## Consequences

**Positive**
- `StateNotifier` and `StateNotifierProvider` fully eliminated from the codebase
- No deprecated API warnings from `flutter_riverpod`
- `riverpod_lint` can be enabled at full strength
- `@riverpod` codegen can be adopted in a future ADR once `riverpod_generator` supports `analyzer >=12.0.0`
- Zero external dependency conflicts — no third-party package is affected

**Negative**
- `ComposerAutoSaveNotifier` handles Android draft-loss prevention (ADR-0086) — manual testing required on Android 10/11 after migration
- Test setup for `ComposerAutoSaveNotifier` becomes less direct: `ProviderContainer` with overrides replaces a plain constructor call
- Codegen path remains blocked until `riverpod_generator` raises its `analyzer` floor
