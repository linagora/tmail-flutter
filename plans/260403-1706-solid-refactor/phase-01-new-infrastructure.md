## Phase 1: Core Infrastructure

**Priority:** P1 | **Status:** pending | **Effort:** 3 days
**Depends on:** Phase 0
**Blocking:** Non-blocking — all changes are new files. Zero conflicts with ongoing feature work.

> All tasks in this phase create new files only. Feature PRs can land on `master` at any time during this phase. No existing controller is touched. No god controller is named.

---

### Tasks

#### 1. `AppEventBus` + wrapper event contracts (day 1)

```dart
// lib/features/base/event_bus/app_event.dart
sealed class AppEvent {}

// lib/features/base/event_bus/events/action_events.dart
/// Wrapper event fired by ActionQueue when a DomainAction succeeds.
/// Listeners subscribe via: eventBus.on<ActionCompleted<MarkAsEmailReadSuccess>>()
class ActionCompleted<T extends Success> extends AppEvent {
  final T result;
  const ActionCompleted(this.result);
}

/// Wrapper event fired by ActionQueue when a DomainAction fails.
class ActionFailed<T extends Failure> extends AppEvent {
  final T failure;
  const ActionFailed(this.failure);
}

// lib/features/base/event_bus/events/session_events.dart
class SessionEstablishedEvent extends AppEvent {
  final Session session;
  final AccountId accountId;
  const SessionEstablishedEvent(this.session, this.accountId);
}

class SessionEndedEvent extends AppEvent {
  const SessionEndedEvent();
}

// lib/features/base/event_bus/app_event_bus.dart
class AppEventBus extends GetxService {
  final _subject = PublishSubject<AppEvent>();

  /// Typed event subscription — the ONLY supported consumption pattern.
  /// Never switch(event) on AppEvent — adding a new subclass silently misses
  /// exhaustive consumers without a compile error.
  Stream<T> on<T extends AppEvent>() => _subject.stream.whereType<T>();

  void emit(AppEvent event) => _subject.add(event);

  @override
  void onClose() {
    _subject.close();
    super.onClose();
  }
}
```

Register in `lib/main/bindings/main_bindings.dart` as permanent, before any other service that depends on it.

**CI rule (already added in Phase 0):** `no_appevent_domain_inheritance` — domain `Success`/`Failure` types are forbidden from extending `AppEvent`.

#### 2. `SessionService` — constructor-injected EventBus, no public setter (day 1)

```dart
// lib/features/base/services/session_service.dart
class SessionService extends GetxService {
  final AppEventBus _eventBus;
  SessionService(this._eventBus);

  final _session = Rxn<Session>();
  final _accountId = Rxn<AccountId>();

  /// Read-only access — no public setter. Writes happen only in the
  /// SessionEstablishedEvent listener below.
  Rxn<Session> get session => _session;
  Rxn<AccountId> get accountId => _accountId;

  StreamSubscription? _sessionEstablishedSub;
  StreamSubscription? _sessionEndedSub;

  @override
  void onInit() {
    super.onInit();
    _sessionEstablishedSub = _eventBus.on<SessionEstablishedEvent>().listen((event) {
      _session.value = event.session;
      _accountId.value = event.accountId;
    });
    _sessionEndedSub = _eventBus.on<SessionEndedEvent>().listen((_) => _clear());
  }

  void _clear() {
    _session.value = null;
    _accountId.value = null;
  }

  @override
  void onClose() {
    _sessionEstablishedSub?.cancel();
    _sessionEndedSub?.cancel();
    super.onClose();
  }
}
```

Register in main bindings, **after** `AppEventBus`:

```dart
Get.put<AppEventBus>(AppEventBus(), permanent: true);
Get.put<SessionService>(SessionService(Get.find<AppEventBus>()), permanent: true);
```

**Login integration (contract only — actual wiring lands in the first Layer 2 phase that touches login):**

```dart
// Login success handler — imports AppEventBus only, never SessionService:
Get.find<AppEventBus>().emit(SessionEstablishedEvent(session, accountId));
```

Phase 1 delivers the contract. Production wiring into login flow is NOT part of Phase 1 — it happens when the first per-controller Layer 2 phase needs an end-to-end session flow.

#### 3. State services with single-writer rule (day 2)

State services own shared Rx references. Each Rx field is documented with its **single writer** — the one delegate (or the service itself) allowed to update it. All other delegates read-only.

```dart
// lib/features/base/services/mailbox_state_service.dart
class MailboxStateService extends GetxService {
  /// Writer: MailboxNavigationDelegate (owned by DashboardDomainRegistry)
  final _selectedMailbox = Rxn<PresentationMailbox>();
  Rxn<PresentationMailbox> get selectedMailbox => _selectedMailbox;
  void updateSelectedMailbox(PresentationMailbox? value) => _selectedMailbox.value = value;

  /// Writer: MailboxNavigationDelegate
  final _selectedMailboxNode = Rxn<SelectedMailboxNode>();
  Rxn<SelectedMailboxNode> get selectedMailboxNode => _selectedMailboxNode;
  void updateSelectedMailboxNode(SelectedMailboxNode? value) => _selectedMailboxNode.value = value;

  /// Writer: MailboxCatalogDelegate
  final _mapMailboxById = <MailboxId, PresentationMailbox>{}.obs;
  RxMap<MailboxId, PresentationMailbox> get mapMailboxById => _mapMailboxById;
  void replaceMailboxMap(Map<MailboxId, PresentationMailbox> value) {
    _mapMailboxById
      ..clear()
      ..addAll(value);
  }

  void clear() {
    _selectedMailbox.value = null;
    _selectedMailboxNode.value = null;
    _mapMailboxById.clear();
  }
}
```

```dart
// lib/features/base/services/email_list_state_service.dart
class EmailListStateService extends GetxService {
  /// Writer: EmailListLoadDelegate
  final _emailsInCurrentMailbox = <PresentationEmail>[].obs;
  RxList<PresentationEmail> get emailsInCurrentMailbox => _emailsInCurrentMailbox;
  void replaceEmails(List<PresentationEmail> value) {
    _emailsInCurrentMailbox
      ..clear()
      ..addAll(value);
  }

  /// Writer: SearchDelegate
  final _listResultSearch = <PresentationEmail>[].obs;
  RxList<PresentationEmail> get listResultSearch => _listResultSearch;
  void replaceSearchResults(List<PresentationEmail> value) {
    _listResultSearch
      ..clear()
      ..addAll(value);
  }

  /// Writer: SearchDelegate
  final _isInSearchMode = false.obs;
  RxBool get isInSearchMode => _isInSearchMode;
  void updateSearchMode(bool value) => _isInSearchMode.value = value;

  void clear() {
    _emailsInCurrentMailbox.clear();
    _listResultSearch.clear();
    _isInSearchMode.value = false;
  }
}
```

**Note:** The delegate names in doc comments (`MailboxNavigationDelegate`, `SearchDelegate`, etc.) are **contracts**, not commitments. When a Layer 2 phase extracts each delegate, it updates the writer name to match the actual delegate it creates. Phase 1 writes the rule; Layer 2 phases fill in the names.

Register both state services in main bindings as permanent.

#### 4. `DomainAction` + `CancellationToken` + `ActionQueue` (day 2)

```dart
// lib/features/base/action/domain_action.dart
/// Base class for all actions submitted to ActionQueue.
/// Subclasses encapsulate parameters and stream creation for one operation.
abstract class DomainAction<R extends Success> {
  /// Unique identifier for this logical operation.
  /// Submitting a new action with an existing tag CANCELS the in-flight one.
  /// Example: 'MarkAsRead:${emailId.value}'
  String get tag;

  /// Creates the domain stream. Called by the queue with session/account.
  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId);
}
```

```dart
// lib/features/base/action/cancellation_token.dart
/// Screen-scoped cancellation. Callbacks skip when cancelled; HTTP still completes.
/// Omit token = background execution (survives controller disposal).
class CancellationToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}
```

```dart
// lib/features/base/action/action_queue.dart
/// Centralised DomainAction execution. Replaces consumeState() for new delegates.
///
/// Contracts:
///   - Tag uniqueness: submit() cancels any in-flight subscription for the same
///     tag before installing the new one.
///   - No-op on missing session: submit() logs and returns if SessionService
///     has no session — it never throws.
///   - Wrapper events: success fires ActionCompleted<T>, failure fires
///     ActionFailed<T>. Domain types are never cast to AppEvent.
///   - cancelAll(): called on session end to purge all in-flight subscriptions.
class ActionQueue extends GetxService {
  final AppEventBus _eventBus;
  final SessionService _session;
  final _active = <String, StreamSubscription>{};

  ActionQueue(this._eventBus, this._session);

  void submit(
    DomainAction action, {
    CancellationToken? token,
    ValueChanged<Success>? onSuccess,
    ValueChanged<Failure>? onFailure,
  }) {
    final session = _session.session.value;
    final accountId = _session.accountId.value;
    if (session == null || accountId == null) {
      log('ActionQueue::submit skipped for ${action.tag} — no session');
      return;
    }

    // Cancel-before-replace: ensures tag collisions do not leak subs.
    _active.remove(action.tag)?.cancel();

    log('ActionQueue::submit ${action.tag}');

    late StreamSubscription sub;
    sub = action.execute(session, accountId).listen(
      (result) => result.fold(
        (failure) {
          _eventBus.emit(ActionFailed(failure));
          if (token?.isCancelled != true) onFailure?.call(failure);
        },
        (success) {
          _eventBus.emit(ActionCompleted(success));
          if (token?.isCancelled != true) onSuccess?.call(success);
        },
      ),
      onDone: () {
        // Only remove if this sub is still the active one for this tag.
        // (A later submit() may have replaced it.)
        if (identical(_active[action.tag], sub)) {
          _active.remove(action.tag);
        }
      },
    );
    _active[action.tag] = sub;
  }

  /// Cancel all in-flight actions. Called on session end.
  void cancelAll() {
    for (final s in _active.values) {
      s.cancel();
    }
    _active.clear();
  }

  @override
  void onClose() {
    cancelAll();
    super.onClose();
  }
}
```

Register in main bindings after `SessionService`:

```dart
Get.put<ActionQueue>(
  ActionQueue(Get.find<AppEventBus>(), Get.find<SessionService>()),
  permanent: true,
);
```

#### 5. `DomainRegistry` contract + lifecycle propagation (day 3)

A `DomainRegistry` is a `GetxService` that owns a group of `ControllerDelegate` instances for one domain (e.g. one screen). The registry is the **only** Layer that calls `Get.find<>()` for infrastructure dependencies — delegates receive pre-resolved references via constructor. The registry drives delegate lifecycle by calling `init()` and `dispose()` from its own `onInit()`/`onClose()`.

```dart
// lib/features/base/delegate/domain_registry.dart
/// Base class for all domain registries.
///
/// A registry is a GetxService that owns a collection of ControllerDelegate
/// instances for one screen or domain. It:
///   1. Resolves all infrastructure dependencies via Get.find<>() (the ONLY
///      layer allowed to do so outside *_bindings.dart files).
///   2. Exposes each delegate as a late final field.
///   3. Calls init() on every delegate in its onInit().
///   4. Calls dispose() on every delegate in its onClose().
///
/// Subclasses override [delegates] to return all owned delegates in creation
/// order. Views access delegates via Get.find<XDomainRegistry>().yDelegate.
abstract class DomainRegistry extends GetxService {
  /// Every delegate owned by this registry, in the order they should be
  /// initialised. Must include every `late final` delegate field.
  List<ControllerDelegate> get delegates;

  @override
  void onInit() {
    super.onInit();
    for (final d in delegates) {
      d.init();
    }
  }

  @override
  void onClose() {
    // Dispose in reverse order so later delegates drop their subscriptions
    // before earlier ones (which may own state those subscriptions read).
    for (final d in delegates.reversed) {
      d.dispose();
    }
    super.onClose();
  }
}
```

**Reference implementation (example only — not shipped in Phase 1):**

```dart
class ExampleDomainRegistry extends DomainRegistry {
  final ActionQueue _queue;
  final SessionService _session;
  final AppEventBus _eventBus;

  ExampleDomainRegistry(this._queue, this._session, this._eventBus);

  late final featureA = FeatureADelegate(_eventBus);
  late final featureB = FeatureBDelegate(_queue, _session);

  @override
  List<ControllerDelegate> get delegates => [featureA, featureB];
}
```

Phase 1 ships `DomainRegistry` as an abstract class only. The first concrete subclass lands in Phase 2 alongside the `NotificationDelegate` pilot.

#### 6. Generic characterization test template (day 3)

Write a test template — not per-controller tests. Layer 2 phase files copy this template when they need characterization coverage before touching a god controller.

```dart
// test/features/base/characterization_template.dart
//
// TEMPLATE: Copy into your Layer 2 phase's test folder, rename, and fill in.
//
// Characterization tests lock CURRENT behavior of a god controller before any
// extraction. They are deliberately NOT unit tests — they mirror the messy
// reality of the controller as it exists today, so that any delegate extraction
// that changes behavior is caught.
//
// After extraction:
//   - Rename the file to match the delegate (e.g., email_action_delegate_test.dart)
//   - Point mocks at the narrow ISP interface, not the fat repository
//   - Point bus assertions at ActionCompleted<XSuccess> wrapper events

void main() {
  group('<Feature> characterization — locks current god-controller behavior', () {
    // TODO(layer2): instantiate the god controller with minimum viable mocks
    // TODO(layer2): list every method / Rx var this phase plans to extract
    // TODO(layer2): one test per extraction target — input, expected output
  });
}
```

Characterization test **authoring** happens inside each Layer 2 phase. Phase 1 ships only the template.

---

### Execution Order

Run `dart run build_runner build --delete-conflicting-outputs` + `flutter test` after each step:

1. `AppEventBus` + wrapper event files (Task 1)
2. `SessionService` with constructor-injected bus (Task 2)
3. `MailboxStateService` + `EmailListStateService` with single-writer rule (Task 3)
4. `ActionQueue` + `DomainAction` + `CancellationToken` (Task 4)
5. `DomainRegistry` abstract base (Task 5)
6. Characterization test template (Task 6)

All Phase 1 files are new. Zero existing controllers are modified.

---

### Success Criteria

- [ ] `AppEventBus` registered as permanent; basic emit/on unit test passes
- [ ] `ActionCompleted<T>` + `ActionFailed<T>` wrapper events defined; no domain type extends `AppEvent`
- [ ] `SessionService` constructor takes `AppEventBus`; no `Get.find` in `onInit`
- [ ] `SessionService` has no public setter; unit test verifies state updates only via `SessionEstablishedEvent`
- [ ] `MailboxStateService` + `EmailListStateService` registered; each Rx field has a documented single-writer delegate name
- [ ] `ActionQueue` registered with cancel-before-replace + `cancelAll()`; tag collision test passes
- [ ] `ActionQueue.submit()` logs + returns when session is null; unit test passes
- [ ] `ActionQueue` fires `ActionCompleted<MockSuccess>` wrapper event in test
- [ ] `DomainRegistry` abstract class created; unit test verifies `init()` / `dispose()` propagation across mock delegates
- [ ] Characterization test template committed in `test/features/base/`
- [ ] `dart run build_runner build --delete-conflicting-outputs` + `flutter test` pass
- [ ] `bash scripts/check_architecture.sh` exits 0 with Phase 0 thresholds (no regression)
