# 92. Upgrade flutter_riverpod to 3.x

Date: 2026-05-28

## Status

Proposed

## Related ADRs

- [ADR-0085](./0085-riverpod-state-management-for-local-settings.md) — introduced `localSettingsNotifierProvider`
- [ADR-0086](./0086-android-composer-draft-loss-on-background.md) — introduced `ComposerAutoSaveNotifier`

## Context

The project uses `flutter_riverpod: ^2.6.1`. Riverpod 3.0 ships two categories of breaking changes that affect this codebase:

**1. `StateNotifier` / `StateNotifierProvider` moved to `legacy.dart`**

They are no longer exported from `flutter_riverpod/flutter_riverpod.dart`. Two files extend `StateNotifier` and declare `StateNotifierProvider`; both become compile errors unless migrated or the import is switched to `flutter_riverpod/legacy.dart`.

**2. `ref.read` inside `Provider` bodies is a lint error**

Riverpod 3.0 enforces `ref.watch` for dependency tracking inside provider factory bodies. `composer_cache_providers.dart` has 6 such call sites.

Other 3.0 changes (automatic retry, `==` update filtering, `AutoDispose` type aliases) do not require code changes in this codebase.

### Why not `@riverpod` codegen

`riverpod_generator` requires `analyzer <10.0.0`. This project pins `analyzer: ">=12.0.0 <13.0.0"` via `dependency_overrides` for `dart_style` and `json_serializable`. No version overlap exists — codegen remains blocked until upstream resolves the constraint.

## Decision

Upgrade to `flutter_riverpod: ^3.0.0` (latest stable: **3.3.1**) using the manual `Notifier` API. No new packages are added.

### Dependency changes

| Package | Current | Target | Notes |
|---|---|---|---|
| `flutter_riverpod` | `^2.6.1` | `^3.0.0` | Direct dep in root `pubspec.yaml` |
| `riverpod` | transitive | transitive | Resolved automatically |
| `riverpod_lint` | — | — | Not used; can be added in a follow-up ADR |
| `riverpod_generator` | — | — | Blocked by `analyzer` constraint — see above |
| `riverpod_annotation` | — | — | Only needed with codegen |

### Logic changes required

#### 1. `LocalSettingsNotifier` — `StateNotifier` → `Notifier`

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

#### 2. `ComposerAutoSaveNotifier` — `StateNotifierProvider.family` → `NotifierProvider.family`

In Riverpod 3.0, `NotifierProvider.family` passes the family argument through the constructor; `build()` takes no parameters. `StateNotifier.mounted` does not exist on `Notifier` — it is replaced by a `_mounted` flag managed via `ref.onDispose`.

```dart
// Before
class ComposerAutoSaveNotifier extends StateNotifier<ComposerAutoSaveState> {
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
  bool _mounted = true;

  ComposerAutoSaveNotifier(this.composerId);

  @override
  ComposerAutoSaveState build() {
    ref.onDispose(() => _mounted = false);
    return const ComposerAutoSaveState();
  }

  bool get mounted => _mounted;
  // methods call ref.read(resolveComposerCacheForRestoreProvider), etc.
}
final composerAutoSaveProvider = NotifierProvider.family<
    ComposerAutoSaveNotifier, ComposerAutoSaveState, String>(
  (id) => ComposerAutoSaveNotifier(id));
```

#### 3. `composer_cache_providers.dart` — `ref.read` → `ref.watch` inside `Provider` bodies

All 6 `ref.read(...)` calls inside `Provider(...)` factory bodies become `ref.watch(...)`. These providers are non-autoDispose singletons; `watch` adds proper dependency tracking with no behavioral difference.

#### 4. Unit tests for `ComposerAutoSaveNotifier`

Interactors are no longer injected via constructor — they are resolved through `ref`. Tests must switch from direct instantiation to `ProviderContainer` with overrides.

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
- `riverpod_lint` can be enabled at full strength in a follow-up
- No new runtime dependencies — a version bump and internal code changes only
- Unblocks a future `@riverpod` codegen ADR once `riverpod_generator` supports `analyzer >=12.0.0`

**Negative**
- `ComposerAutoSaveNotifier` owns Android draft-loss prevention (ADR-0086) — manual testing on Android required after migration
- `_mounted` via `ref.onDispose` fires when the provider element is torn down (on `invalidate`), not synchronously — verify stale-write guards in `handle_mobile_auto_save_extension.dart` still hold
- `ComposerAutoSaveNotifier` test setup is less direct: `ProviderContainer` with overrides replaces a plain constructor call
