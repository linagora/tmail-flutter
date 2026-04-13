## Phase 2: BaseController, DI Refactor, and Pilot Delegate

**Priority:** P1 | **Status:** pending | **Effort:** 4 days
**Depends on:** Phase 0 + Phase 1
**Blocks:** All Layer 2 per-controller phases

> **Coordination window.** This phase modifies `BaseController`, `ReloadableController`, several bindings files, and the notification feature. Notify the team before starting. Feature branches touching these files should rebase after this phase lands.
>
> Duration is short (4 days) by design. After this phase, Layer 2 per-controller phases run in git worktrees and `master` is always open for feature work.
>
> **This phase ships one production delegate — `NotificationDelegate`.** It is chosen because it has zero coupling to the largest god controllers, so it proves the full extraction loop (delegate → registry → view → test → CI) on a low-risk target.

---

### Tasks

#### 1. `ReloadableController` — constructor injection

Remove field-level `Get.find` calls. Pass interactors via constructor.

```dart
// lib/features/base/reloadable/reloadable_controller.dart
abstract class ReloadableController extends BaseController {
  final GetSessionInteractor _getSessionInteractor;
  final GetAuthenticatedAccountInteractor _getAuthenticatedAccountInteractor;
  final UpdateAccountCacheInteractor _updateAccountCacheInteractor;
  final GetOidcUserInfoInteractor _getOidcUserInfoInteractor;

  ReloadableController(
    this._getSessionInteractor,
    this._getAuthenticatedAccountInteractor,
    this._updateAccountCacheInteractor,
    this._getOidcUserInfoInteractor,
  );
}
```

Update all subclasses to pass through constructor args. Run `dart run build_runner build --delete-conflicting-outputs`.

#### 2. `BaseController` strip — 4 focused services

Extract the 14 field-level `Get.find` calls currently living on `BaseController` into **four focused services**. After this task, `BaseController` is ≤250 LOC and contains only lifecycle concerns (`workerObxVariables`, `_stateSubscriptions`, `onClose`).

```dart
// lib/features/base/services/auth_service.dart
class AuthService extends GetxService {
  final AuthorizationInterceptors authInterceptors;
  final AuthorizationInterceptors authIsolateInterceptors;
  final DynamicUrlInterceptors dynamicUrlInterceptors;
  final DeleteCredentialInteractor deleteCredential;
  final LogoutOidcInteractor logoutOidc;
  final DeleteAuthorityOidcInteractor deleteAuthorityOidc;

  AuthService(
    this.authInterceptors, this.authIsolateInterceptors,
    this.dynamicUrlInterceptors, this.deleteCredential,
    this.logoutOidc, this.deleteAuthorityOidc,
  );
}

// lib/features/base/services/cache_service.dart
class CacheService extends GetxService {
  final CachingManager cachingManager;
  final LanguageCacheManager languageCacheManager;
  CacheService(this.cachingManager, this.languageCacheManager);
}

// lib/features/base/services/ui_service.dart
class UIService extends GetxService {
  final AppToast appToast;
  final Uuid uuid;
  final ToastManager toastManager;
  final TwakeAppManager twakeAppManager;
  UIService(this.appToast, this.uuid, this.toastManager, this.twakeAppManager);
}

// lib/features/base/services/view_context_service.dart
/// Pure view-layer helpers that controllers and views both read.
/// Previously held as BaseController fields; moved here to keep the base lean.
class ViewContextService extends GetxService {
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  ViewContextService(this.imagePaths, this.responsiveUtils);
}
```

Register all four as permanent in `main_bindings.dart`. Remove the 14 field declarations from `BaseController`.

Update `LogoutMixin` to use `Get.find<AuthService>()` instead of BaseController fields.

For legacy controllers accessing `appToast`/`uuid`/`toastManager`/`imagePaths`/`responsiveUtils` via inheritance: use `Get.find<UIService>().appToast` or `Get.find<ViewContextService>().imagePaths` inline. Do NOT mass-migrate — only fix compilation errors. A lingering tech-debt TODO is fine and is tracked by the CI `VIOLATIONS_MAX` ratchet.

**Target:** `BaseController` ≤250 LOC after extraction.

#### 3. Bindings split

Break large dashboard/composer bindings files into domain-scoped files. This is a **transitional** structure — the per-controller Layer 2 phase for each screen replaces individual delegate registration with a `DomainRegistry` entry.

Example layout for a dashboard-style bindings folder:

```
lib/features/<screen>/presentation/bindings/
  ├── <screen>_bindings.dart             # orchestrator (~30 LOC)
  ├── <screen>_email_interactor_bindings.dart
  ├── <screen>_mailbox_interactor_bindings.dart
  ├── <screen>_search_interactor_bindings.dart
  └── <screen>_composer_interactor_bindings.dart
```

Each file ≤60 LOC. The orchestrator calls `.dependencies()` on each sub-binding. **Do not** pre-register domain registries here — they appear when the Layer 2 phase for that screen extracts its first delegate.

#### 4. Standardise DI patterns

Replace field-level `Get.find` calls in sub-controllers with constructor injection via bindings. Target any controller that currently pulls its collaborators via `Get.find` at field-init time. After this task, `BaseController` subclasses never do `Get.find` in a field initializer.

Do NOT attempt to migrate every legacy controller — scope this task to subclasses of `BaseController` and `ReloadableController`. Track progress against the CI `VIOLATIONS_MAX` threshold.

#### 5. Panel-scoped binding migration (DIP cleanup)

**Category A — panel widget-swap controllers:**

| Violation | Fix |
|---|---|
| Controller calls `XBindings().dependencies()` mid-method (panel binding triggered from user navigation) | Move registration to the parent binding using `Get.lazyPut(fenix: true)`; panel creation happens on first `Get.find<>()` |
| Controller calls `XBindings().disposeBindings()` on exit | Replace with `Get.delete<XController>(force: true)` directly |

In each `XBindings.bindingsController()`: change `Get.put(XController(...))` → `Get.lazyPut(() => XController(...), fenix: true)`. `fenix: true` lets a deleted controller be recreated on the next widget build without a binding call from the controller body.

**Category B — account/settings panel bindings:**

Move any sub-panel bindings called inside a panel-switching method to the parent route's binding. Delete the `_bindingControllerMenuItemView`-style methods once all sub-bindings are registered at route startup.

**Accepted exceptions (do NOT migrate):**

- `inject*()` methods in `BaseController` / `ReloadableController` — capability-gated interactor bindings (JMAP capabilities are only known after session establishment).
- `fcm_message_controller.dart` — background FCM isolate bootstrap needs a full re-DI.
- `main_entry.dart` — app startup.

After this task: ratchet CI `BINDING_VIOLATIONS_MAX` to 0.

#### 6. Pilot delegate — `NotificationDelegate` shipped to production

Pick `NotificationDelegate` as the pilot because notification settings are self-contained: no Rxn dispatch stream coupling, no cross-controller reads, no shared state with the large god controllers. If the pilot loop works for Notification, it will work for any target.

**Scope:** Extract the notification settings feature into a `ControllerDelegate` subclass and a `NotificationDomainRegistry`. Ship it. No feature flag — the old code path is deleted in the same commit.

```dart
// lib/features/notification/presentation/delegates/notification_delegate.dart
class NotificationDelegate extends ControllerDelegate {
  final ActionQueue _queue;
  final AppEventBus _eventBus;
  final INotificationSettingsRepository _repo;

  NotificationDelegate(this._queue, this._eventBus, this._repo);

  final isEnabled = RxBool(false);
  final isLoading = RxBool(false);

  @override
  void init() {
    super.init();
    _loadSettings();
    trackSub(
      _eventBus
          .on<ActionCompleted<UpdateNotificationSettingsSuccess>>()
          .listen(_onSettingsUpdated),
    );
  }

  void toggleNotifications(bool value) {
    isLoading.value = true;
    _queue.submit(
      UpdateNotificationSettingsAction(value, _repo),
      onSuccess: (_) => isEnabled.value = value,
      onFailure: (_) => isLoading.value = false,
    );
  }

  void _loadSettings() { /* ... */ }
  void _onSettingsUpdated(ActionCompleted<UpdateNotificationSettingsSuccess> e) {
    isLoading.value = false;
  }
}
```

```dart
// lib/features/notification/presentation/registries/notification_domain_registry.dart
class NotificationDomainRegistry extends DomainRegistry {
  final ActionQueue _queue;
  final AppEventBus _eventBus;
  final INotificationSettingsRepository _repo;

  NotificationDomainRegistry(this._queue, this._eventBus, this._repo);

  late final settings = NotificationDelegate(_queue, _eventBus, _repo);

  @override
  List<ControllerDelegate> get delegates => [settings];
}
```

**Binding wiring:**

```dart
// lib/features/notification/presentation/bindings/notification_bindings.dart
class NotificationBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<INotificationSettingsRepository>(() => NotificationSettingsRepositoryImpl(...));
    Get.lazyPut<NotificationDomainRegistry>(() => NotificationDomainRegistry(
      Get.find<ActionQueue>(),
      Get.find<AppEventBus>(),
      Get.find<INotificationSettingsRepository>(),
    ), fenix: true);
  }
}
```

**View wiring:**

```dart
// Views read via the registry — never Get.find<NotificationDelegate>()
Obx(() {
  final d = Get.find<NotificationDomainRegistry>().settings;
  return Switch(
    value: d.isEnabled.value,
    onChanged: d.isLoading.value ? null : d.toggleNotifications,
  );
});
```

**Deliverables for the pilot:**

- `NotificationDelegate` (≤200 LOC) subclassing `ControllerDelegate`
- `NotificationDomainRegistry` subclassing `DomainRegistry`
- `INotificationSettingsRepository` ISP interface
- Existing fat repository implements the new interface (no data layer changes)
- Views rewritten to read via the registry
- Unit test suite for the delegate, mocking the ISP interface and `ActionQueue`
- `DomainRegistry.init()` / `dispose()` lifecycle verified in test (worker count before/after)
- Old notification controller + its bindings deleted
- Smoke test on web + mobile: toggle notifications → settings persist → reload → state restored
- CI script green

If the pilot fails end-to-end smoke, STOP. Do not start Layer 2 phases. Debug and re-pilot until it ships.

---

### Execution Order

Run `dart run build_runner build --delete-conflicting-outputs` + `flutter test` after each step:

1. `ReloadableController` ctor injection (Task 1)
2. `AuthService` / `CacheService` / `UIService` / `ViewContextService` extraction (Task 2)
3. Bindings split (Task 3)
4. Standardise DI patterns (Task 4)
5. Panel-scoped binding migration (Task 5)
6. `NotificationDelegate` pilot (Task 6) — ships to production

Update CI YAML at end of phase: `BASE_MAX=250`, `BINDING_VIOLATIONS_MAX=0`, `RELOAD_MAX=0`, remove `SKIP_BINDING_CHECK`.

---

### Success Criteria

- [ ] `ReloadableController` has 0 field-level `Get.find` calls; all subclasses updated; mocks regenerated
- [ ] `BaseController` ≤250 LOC; `AuthService`, `CacheService`, `UIService`, `ViewContextService` registered as permanent GetxServices
- [ ] `LogoutMixin` uses `AuthService` (not `BaseController` fields)
- [ ] Panel-scoped binding migration complete; `BINDING_VIOLATIONS_MAX=0`
- [ ] Bindings split into ≤60 LOC files; `SKIP_BINDING_CHECK` removed from CI
- [ ] `NotificationDelegate` shipped to production, extends `ControllerDelegate`
- [ ] `NotificationDomainRegistry` extends `DomainRegistry`; `init()`/`dispose()` propagation verified by test
- [ ] `INotificationSettingsRepository` ISP interface created; fat repository silently implements it
- [ ] Old notification controller and its bindings deleted
- [ ] Smoke test: notification toggle works on web + mobile; state persists
- [ ] `bash scripts/check_architecture.sh` exits 0 with Phase 2 thresholds (`BASE_MAX=250`, `BINDING_VIOLATIONS_MAX=0`, `RELOAD_MAX=0`)
- [ ] `flutter analyze` + `flutter test` pass
