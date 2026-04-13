# 80. SOLID Refactor — God Controller Decomposition

Date: 2026-04-03
Last revised: 2026-04-13 (abstract pattern plan)

## Status

Accepted

## Context

The presentation layer has accumulated god controllers that violate every SOLID principle. A god controller is any controller exceeding ~700 LOC, owning 3+ unrelated domains, or accumulating 10+ constructor dependencies.

Typical symptoms of a god controller:
- Multiple unrelated mixins on a single controller; many extension files all extending `on GodController` (accessing `this.selectedMailbox`, `this.accountId`, etc. — tightly coupled through `this`)
- Other features call `Get.find<GodController>()` to reach state or invoke actions that belong to a specific domain
- A single bindings file with dozens of `Get.put`/`Get.lazyPut` calls, one per dependency
- Zero delegates despite the pattern being documented in `CLAUDE.md`
- Test files mock the god controller — mocking a 40+ dependency controller is expensive and fragile

At the time this ADR was written, the largest god controller had ~3500 LOC, 40+ dependencies, and 10+ unrelated domains. Its bindings file exceeded 500 LOC with 100+ registration calls. Another screen-level controller had ~2400 LOC and 10 domains. `BaseController` itself had accumulated 14 field-level `Get.find` calls for auth, cache, and UI utilities — concerns unrelated to its lifecycle role.

The codebase **cannot grow sustainably** in this state — new features are added by appending to god controllers, which compounds the problem.

## Architecture

### Core patterns

#### 1. Controller Delegate — plain Dart class, lifecycle propagated by DomainRegistry

A delegate owns one feature's state and behaviour. The canonical `ControllerDelegate` is a **plain Dart class** — not a `GetxController`, not a `BaseController`. Its lifecycle is driven by its owning `DomainRegistry` via `init()` / `dispose()`.

This is a deliberate fix for a GetX hazard: when a delegate is stored as a `late final` field inside a `GetxService` (the registry), GetX never calls `onInit`/`onClose` on the delegate. Workers leak. Plain Dart classes with explicit `init`/`dispose` controlled by the registry avoid this entirely.

```dart
// lib/features/base/delegate/controller_delegate.dart
abstract class ControllerDelegate {
  final _workers = <Worker>[];
  final _subs = <StreamSubscription>[];

  @protected
  Worker trackWorker(Worker worker) { _workers.add(worker); return worker; }

  @protected
  StreamSubscription<T> trackSub<T>(StreamSubscription<T> sub) { _subs.add(sub); return sub; }

  @mustCallSuper void init() {}

  @mustCallSuper
  void dispose() {
    for (final w in _workers) w.dispose();
    for (final s in _subs) s.cancel();
    _workers.clear();
    _subs.clear();
  }
}
```

```dart
// Example — extracted in a per-controller Layer 2 phase, not in the foundation
class EmailActionDelegate extends ControllerDelegate {
  final ActionQueue _queue;
  final SessionService _session;
  final MailboxStateService _mailboxState;
  final IEmailMoveRepository _moveRepo;

  EmailActionDelegate(this._queue, this._session, this._mailboxState, this._moveRepo);

  final listEmailSelected = RxList<PresentationEmail>([]);

  @override
  void init() {
    super.init();
    trackWorker(ever(_mailboxState.selectedMailbox, (_) => _clearSelection()));
  }

  void moveToTrash(PresentationEmail email) =>
      _queue.submit(MoveToTrashAction(email, _moveRepo));
}
```

**Rule:** delegates never call `Get.find<>()` in their own body. They receive pre-resolved dependencies from the registry constructor. The only places where `Get.find<>()` appears are `*_bindings.dart` files and `DomainRegistry` subclasses.

#### 2. DomainRegistry — single DI entry, lifecycle propagation

A `DomainRegistry` is a `GetxService` that owns a group of delegates for one screen or domain. It:

1. Resolves all infrastructure dependencies via `Get.find<>()` — the **only** layer allowed to do so outside `*_bindings.dart`.
2. Exposes each delegate as a `late final` field.
3. Calls `init()` on every delegate in its own `onInit()`.
4. Calls `dispose()` on every delegate in reverse order in its `onClose()`.

```dart
// lib/features/base/delegate/domain_registry.dart
abstract class DomainRegistry extends GetxService {
  List<ControllerDelegate> get delegates;

  @override
  void onInit() {
    super.onInit();
    for (final d in delegates) d.init();
  }

  @override
  void onClose() {
    for (final d in delegates.reversed) d.dispose();
    super.onClose();
  }
}
```

```dart
class DashboardDomainRegistry extends DomainRegistry {
  final ActionQueue _queue;
  final SessionService _session;
  final AppEventBus _eventBus;
  final MailboxStateService _mailboxState;
  final EmailListStateService _emailListState;

  DashboardDomainRegistry(
    this._queue, this._session, this._eventBus,
    this._mailboxState, this._emailListState,
  );

  late final emailAction = EmailActionDelegate(
    _queue, _session, _mailboxState,
    Get.find<IEmailMoveRepository>(),
  );
  late final search = SearchDelegate(_session, _emailListState);

  @override
  List<ControllerDelegate> get delegates => [emailAction, search];
}

// View access via the registry:
Get.find<DashboardDomainRegistry>().emailAction.moveToTrash(email);
```

Adding a new delegate = one `late final` line + one entry in `delegates`. Zero bindings edits.

#### 3. AppEventBus — wrapper events, no domain inheritance

Cross-feature announcements flow through a typed event bus. Domain `Success`/`Failure` types belong to the domain layer and **must not** extend `AppEvent` — that would invert the dependency rule and break Clean Architecture. Cross-feature delivery uses **wrapper events** defined in the base layer.

```dart
// lib/features/base/event_bus/app_event.dart
sealed class AppEvent {}

// lib/features/base/event_bus/events/action_events.dart
class ActionCompleted<T extends Success> extends AppEvent {
  final T result;
  const ActionCompleted(this.result);
}

class ActionFailed<T extends Failure> extends AppEvent {
  final T failure;
  const ActionFailed(this.failure);
}

// lib/features/base/event_bus/app_event_bus.dart
class AppEventBus extends GetxService {
  final _subject = PublishSubject<AppEvent>();

  Stream<T> on<T extends AppEvent>() => _subject.stream.whereType<T>();
  void emit(AppEvent event) => _subject.add(event);

  @override void onClose() { _subject.close(); super.onClose(); }
}
```

**Scope of named events:** intentional cross-feature commands (`SessionEstablishedEvent`, `SessionEndedEvent`, `ComposerOpenedEvent`, `SpamBannerRefreshEvent`). Domain outcomes use `ActionCompleted<T>` / `ActionFailed<T>` wrappers fired by `ActionQueue`.

**Rule:** Always consume via `eventBus.on<T>().listen(...)`. Never use `switch (event)` on `AppEvent` directly — adding a new subclass would silently miss exhaustive-switch consumers without a compile error.

#### 4. SessionService — constructor-injected EventBus, no public setter

`SessionService` holds the session as read-only Rx refs. Writes happen **only** inside its own `SessionEstablishedEvent` listener. There is no public setter. The login feature emits an event — it never imports `SessionService`.

`AppEventBus` is passed via the constructor (not via `Get.find` in `onInit`), so `SessionService` is DIP-compliant and testable without the DI container.

```dart
class SessionService extends GetxService {
  final AppEventBus _eventBus;
  SessionService(this._eventBus);

  final _session = Rxn<Session>();
  final _accountId = Rxn<AccountId>();
  Rxn<Session> get session => _session;
  Rxn<AccountId> get accountId => _accountId;

  StreamSubscription? _established;
  StreamSubscription? _ended;

  @override
  void onInit() {
    super.onInit();
    _established = _eventBus.on<SessionEstablishedEvent>().listen((e) {
      _session.value = e.session;
      _accountId.value = e.accountId;
    });
    _ended = _eventBus.on<SessionEndedEvent>().listen((_) {
      _session.value = null;
      _accountId.value = null;
    });
  }

  @override
  void onClose() {
    _established?.cancel();
    _ended?.cancel();
    super.onClose();
  }
}
```

```dart
// Login success handler — emits only:
Get.find<AppEventBus>().emit(SessionEstablishedEvent(session, accountId));
```

#### 5. State services — single-writer rule

State that multiple delegates need (session, selected mailbox, email list) moves to dedicated `GetxService` instances. Delegates depend on state services, not on god controllers. Each Rx field is documented with its **single writer** — the one delegate (or the service itself) allowed to update it. Other delegates read-only.

```dart
class MailboxStateService extends GetxService {
  /// Writer: MailboxNavigationDelegate
  final _selectedMailbox = Rxn<PresentationMailbox>();
  Rxn<PresentationMailbox> get selectedMailbox => _selectedMailbox;
  void updateSelectedMailbox(PresentationMailbox? value) => _selectedMailbox.value = value;

  /// Writer: MailboxCatalogDelegate
  final _mapMailboxById = <MailboxId, PresentationMailbox>{}.obs;
  RxMap<MailboxId, PresentationMailbox> get mapMailboxById => _mapMailboxById;
  void replaceMailboxMap(Map<MailboxId, PresentationMailbox> v) {
    _mapMailboxById..clear()..addAll(v);
  }

  void clear() { _selectedMailbox.value = null; _mapMailboxById.clear(); }
}
```

State services expose `update*` / `replace*` methods — never a public setter. Cross-delegate reads are OK; cross-delegate writes go through the named owner or an event.

Both state services registered as permanent in `main_bindings.dart`. Cleared (not deleted) on logout via the `SessionEndedEvent` listener; reused on re-login.

#### 6. ActionQueue — centralised async execution

`consumeState()` is `@Deprecated`. New delegates submit self-contained action objects to a centralised queue. The queue:

1. **Cancel-before-replace.** Submitting a new action with an existing `tag` cancels the in-flight subscription first — preventing leaked subs on tag collision.
2. **No-op on missing session.** If `SessionService` has no session, `submit()` logs and returns. It never throws.
3. **Wrapper events.** Success fires `ActionCompleted<T>`; failure fires `ActionFailed<T>`. Domain types are never cast to `AppEvent`.
4. **`cancelAll()`.** Called on `onSessionEnd()` to purge all in-flight subscriptions before session-scoped services are deleted.

```dart
abstract class DomainAction<R extends Success> {
  String get tag; // e.g. 'MarkAsRead:${emailId.value}'
  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId);
}

class ActionQueue extends GetxService {
  final AppEventBus _eventBus;
  final SessionService _session;
  final _active = <String, StreamSubscription>{};

  ActionQueue(this._eventBus, this._session);

  void submit(DomainAction action, {CancellationToken? token, ValueChanged<Success>? onSuccess, ValueChanged<Failure>? onFailure}) {
    final s = _session.session.value;
    final id = _session.accountId.value;
    if (s == null || id == null) { log('ActionQueue::submit skipped ${action.tag}'); return; }

    _active.remove(action.tag)?.cancel(); // cancel-before-replace

    late StreamSubscription sub;
    sub = action.execute(s, id).listen(
      (result) => result.fold(
        (f) { _eventBus.emit(ActionFailed(f)); if (token?.isCancelled != true) onFailure?.call(f); },
        (r) { _eventBus.emit(ActionCompleted(r)); if (token?.isCancelled != true) onSuccess?.call(r); },
      ),
      onDone: () { if (identical(_active[action.tag], sub)) _active.remove(action.tag); },
    );
    _active[action.tag] = sub;
  }

  void cancelAll() {
    for (final s in _active.values) s.cancel();
    _active.clear();
  }

  @override void onClose() { cancelAll(); super.onClose(); }
}
```

**`CancellationToken`:** screen-scoped callbacks skip when cancelled; HTTP still completes. Omit token = background execution that survives controller disposal.

#### 7. BaseController strip — four focused services

`BaseController` accumulated 14 field-level `Get.find` calls unrelated to lifecycle. Delegates that need a GetxController base (rare — the default is plain `ControllerDelegate`) must inherit a lean base, not 14 unrelated dependencies. Extract into four services registered in `main_bindings.dart`:

- `AuthService` — auth interceptors, logout interactors.
- `CacheService` — caching managers.
- `UIService` — toast, uuid, toast manager, app manager.
- `ViewContextService` — `imagePaths`, `responsiveUtils`. View-layer helpers that both views and controllers read.

After extraction, `BaseController` ≤250 LOC. It retains only lifecycle concerns (`workerObxVariables`, `_stateSubscriptions`, `onClose`).

#### 8. DIP rule: `Get.find<>()` and `XBindings().dependencies()` only in bindings + registries

Controllers and delegates declare dependencies in their constructors. `Get.find<>()` and `XBindings().dependencies()` appear only inside `*_bindings.dart` files and `DomainRegistry` subclasses — never in business logic.

**Accepted exceptions:**

| Exception | Reason |
|---|---|
| `inject*()` methods in `BaseController` / `ReloadableController` | JMAP capabilities are only known after session establishment; capability-gated interactor bindings are permitted here and must register interactors only — never controllers |
| `fcm_message_controller.dart` | Dart isolate for background push must re-bootstrap full DI |
| `main_entry.dart` | App startup |

**Panel-scoped widget-swap pattern** — on web, some panels are rendered via widget swap (not `Get.toNamed`/`GetPage`). GetX does NOT manage their lifecycle automatically. The fix: register panel controllers in the **parent route's binding** using `Get.lazyPut(fenix: true)`, and dispose via `Get.delete<XController>(force: true)` in the exit handler — never via `XBindings().disposeBindings()` from a controller body.

**Enforcement:**

- **Runtime:** `scripts/check_architecture.sh` — auto-discovering LOC gate for controllers ≥700 LOC, plus grep-based rules for `Get.find` placement, bare `ever()`, binding calls, cross-feature datasource injection, and domain `AppEvent` inheritance.
- **IDE:** `custom_lint` package at `tools/tmail_lint/` with four rules: `avoid_bare_ever`, `no_get_find_outside_bindings`, `no_binding_call_outside_bindings`, `no_appevent_domain_inheritance`.

The CI script runs on every PR and is authoritative. Lint rules catch violations in-IDE before CI.

#### 9. ISP for repositories

Split fat repository interfaces into focused ones per delegate. Each delegate depends **only** on the interface covering its domain. Existing fat repositories silently implement all the narrow interfaces — zero data-layer changes.

Narrow interfaces are declared **just-in-time**: in the same commit that creates the delegate consuming them. No upfront interface sprawl.

#### 10. Session lifecycle protocol

Explicit create/clear/delete contract at each session boundary:

```dart
void onSessionReady(Session session, AccountId accountId) {
  Get.find<AppEventBus>().emit(SessionEstablishedEvent(session, accountId));
  // SessionService + state services react to the event and populate.

  // Session-scoped registries (created by per-controller Layer 2 phases):
  Get.put(XDomainRegistry(...));
}

void onSessionEnd() {
  Get.find<AppEventBus>().emit(const SessionEndedEvent());
  // SessionService + state services react to SessionEndedEvent and clear.

  Get.find<ActionQueue>().cancelAll();

  // Session-scoped registries: delete (onClose disposes every delegate)
  Get.delete<XDomainRegistry>();
}
```

| Tier | Components | Created | Destroyed |
|---|---|---|---|
| **Boot** (permanent) | `AppEventBus`, `ActionQueue`, `SessionService`, state services, `AuthService`, `CacheService`, `UIService`, `ViewContextService` | `main_bindings.dart` | Never (cleared on `SessionEndedEvent`) |
| **Session** | Session-scoped domain registries | `onSessionReady()` | `onSessionEnd()` |
| **Route** | Route-scoped domain registries, screen controllers | Route binding | Route pop |
| **Widget** | Micro-controllers | Widget build | Widget dispose |

The foundation plan establishes this contract. Actual integration into login/logout flow happens in the first per-controller Layer 2 phase that requires a session-scoped registry.

#### 11. Operation lifetime classification

| Duration | Owner | Example |
|---|---|---|
| Instant (<1s) | Delegate | Toggle star, mark read |
| Short (1–5s) | Delegate + toast on fail | Move to folder |
| Long (>5s, user may navigate) | Session-lifetime service | Download, send email, empty trash |
| Background (survives app) | Platform service (WorkManager / FCM) | FCM sync, sending queue |

Long-running controllers are reclassified as session-lifetime `GetxService` instances by the per-controller phase that touches them. Views observe via `Get.find<XService>().state` — independent of any screen controller.

### Target metrics (foundation)

Per-controller LOC targets are tracked in each controller's Layer 2 phase file when it is created. Foundation targets apply after Phases 0–2 land:

| Metric | Target | When |
|---|---|---|
| `BaseController` LOC | ≤250 | Phase 2 |
| `ReloadableController` field `Get.find` | 0 | Phase 2 |
| Bare `ever()` calls | 0 (ratcheted) | Foundation → Layer 2 |
| `Get.find<>()` outside bindings | ratcheted from current baseline | Foundation → Layer 2 |
| `XBindings().dependencies()` outside bindings | 0 | Phase 2 |
| Cross-feature `DataSource` in bindings | 0 (CI-enforced) | Foundation |
| Domain types extending `AppEvent` | 0 (CI-enforced) | Phase 0 |
| Controllers >700 LOC | Auto-discovered + gated (no regressions) | Phase 0 |
| Pilot delegate | `NotificationDelegate` shipped to production | Phase 2 |

Per-controller targets (LOC reduction, delegate count, Rxn elimination, ISP interfaces, session lifecycle wiring) are owned by each Layer 2 phase file.

### Refactor phases

See `plans/260403-1706-solid-refactor/plan.md` for the full phased plan.

| Phase | What | Blocking | Effort |
|---|---|---|---|
| 0 | Safety Foundation: `workerObxVariables` → `BaseController`, `consumeState()` stream fix + `@Deprecated`, `ControllerDelegate` abstract base class, auto-discovering CI script, `custom_lint` package | Non-blocking — additive only | 2d |
| 1 | Core Infrastructure: `AppEventBus` + wrapper events, constructor-injected `SessionService`, state services with single-writer rule, `ActionQueue` + `DomainAction` + `CancellationToken` (cancel-before-replace, `cancelAll()`), `DomainRegistry` abstract base with lifecycle propagation, characterization test template | Non-blocking — new files only | 3d |
| 2 | BaseController strip (→≤250 LOC), `ReloadableController` ctor injection, `AuthService` / `CacheService` / `UIService` / `ViewContextService` extraction, bindings split, panel-scoped binding migration, **`NotificationDelegate` pilot shipped to production** | **4-day coordination window** | 4d |
| N | Generic per-controller extraction protocol (template). One instance created JIT per god controller, smallest LOC first. Runs in git worktrees. Includes domain table discovery, delegate extraction, Rxn→wrapper-event migration, satellite decoupling, session lifecycle wiring (if session-scoped). | Non-blocking (git worktree) | per controller |

**Foundation total: ~2 weeks.** Per-controller phases are scheduled independently.

---

## How to refactor without regression

### Zero-tolerance regression rules (enforce before every commit)

1. `workerObxVariables.add(ever(...))` for GetxControllers; `trackWorker(ever(...))` for `ControllerDelegate`. Never bare `ever()`.
2. `consumeState()` is `@Deprecated`. Zero NEW callers in delegates or registries.
3. Every `ControllerDelegate` with EventBus subscriptions stores and cancels them via `trackSub(...)`.
4. `SessionService` has no public setter; writes happen only in the `SessionEstablishedEvent` / `SessionEndedEvent` listeners.
5. One delegate per commit, CI green before the next extraction starts.
6. Each decomposition phase file owns the event files it introduces — no cross-phase edits to event files.
7. `Get.find<>()` never inside delegate bodies, extension methods, or mixin bodies. Bindings + `DomainRegistry` subclasses only.
8. `XBindings().dependencies()` never called from a controller body (accepted exceptions: `inject*()` methods in `BaseController`/`ReloadableController`, `fcm_message_controller.dart`, `main_entry.dart`).
9. Domain `Success`/`Failure` types never extend `AppEvent`. Cross-feature delivery uses `ActionCompleted<T>` wrapper events or named base-layer events.
10. `ActionQueue.submit()` cancels any existing subscription for the same `tag` before installing a new one.
11. `ActionQueue.cancelAll()` is called on `onSessionEnd()` — no orphaned streams survive logout.
12. Every Rxn action type owned by a delegate is replaced with a typed wrapper event in the same commit as the delegate extraction. When all types for a Rxn stream are migrated, the Rxn field is deleted.
13. `ControllerDelegate` is a plain Dart class (not a `BaseController`). It does not appear in `Get.find<>()` directly — it is owned by its registry.
14. State services expose one `update*` method per Rx var, documented with the name of the single writer delegate.

### Delegate extraction process (per delegate)

1. Identify the domain boundary from the Layer 2 phase's Day 0 table.
2. Write characterization tests against the current god controller before touching production code.
3. Create the narrow ISP repository interface.
4. Extract the delegate (subclass `ControllerDelegate`, no `Get.find`, track workers and subs).
5. Add a forwarding stub in the god controller — keeps the codebase green during transition.
6. Migrate Rxn action types owned by this delegate to typed wrapper events.
7. Add a `late final` field in the domain registry (creating the registry if this is the first delegate for the screen).
8. Update views to read via the registry: `Get.find<XDomainRegistry>().y.doThing(...)`.
9. Migrate tests inline — mock the ISP interface and `ActionQueue`, not the fat repository or god controller.
10. Run `dart run build_runner build --delete-conflicting-outputs`.
11. Delete forwarding stub + absorbed extension files.
12. Full regression gate: `flutter analyze && flutter test && bash scripts/check_architecture.sh`.
13. One delegate per commit.

If tests fail after extraction: revert the extraction, not the tests.

---

## How new features must be added (SOLID compliance)

### Rule: new capability = new `ControllerDelegate` subclass + one `late final` line in the registry

**Never add state or logic to an existing controller.** Instead:

1. Create a delegate at `lib/features/{feature}/presentation/delegates/{capability}_delegate.dart` extending `ControllerDelegate`.
2. Create a narrow ISP interface if repository access is needed.
3. Add a `late final` field in the domain registry (and include it in `delegates`).
4. Bind the view via the registry: `Get.find<XDomainRegistry>().snooze.snoozedEmails`.

The existing controller and bindings are **never modified**. Zero bindings edits.

### Decision table

| Situation | Pattern | Location |
|---|---|---|
| New UI state for an existing screen | `ControllerDelegate` via domain registry | `presentation/delegates/` |
| State shared across 2+ features | `GetxService` | `presentation/services/` |
| Stateless helper (pure function) | Extension method | `presentation/extensions/` |
| New usecase coordination | `ControllerDelegate` with `ActionQueue.submit()` | `presentation/delegates/` |
| Cross-feature event (e.g. email sent → refresh thread) | `AppEventBus` event | emit in delegate, listen in another delegate |

### Example: adding "Snooze email"

```
❌ Wrong: open mailbox_dashboard_controller.dart and add snoozeEmail() + snoozeUntil Rx

✓ Correct:
  1. Create lib/features/mailbox_dashboard/presentation/delegates/snooze_delegate.dart
     extends ControllerDelegate
     - Deps: ActionQueue, SessionService, ISnoozeRepository (narrow ISP interface)
     - State: RxList<SnoozedEmail> snoozedEmails
     - Method: void snoozeEmail(email, duration) => _queue.submit(SnoozeAction(...))

  2. Add to DashboardDomainRegistry:
     late final snooze = SnoozeDelegate(_queue, _session, Get.find<ISnoozeRepository>());
     // and append `snooze` to the `delegates` list
     // Zero changes to bindings file

  3. Bind view widget via registry:
     Obx(() => Get.find<DashboardDomainRegistry>().snooze.snoozedEmails.isEmpty
       ? SizedBox.shrink()
       : SnoozeListWidget())
```

### Checklist for any new feature PR

- [ ] No new methods added to an existing god controller
- [ ] New delegate extends `ControllerDelegate`, < 200 LOC
- [ ] Delegate constructor lists all dependencies explicitly (no `Get.find<>()` inside)
- [ ] Delegate uses `ActionQueue.submit()` for async operations — never `consumeState()`
- [ ] All `ever()` / `debounce()` calls wrapped in `trackWorker(...)`
- [ ] Delegate depends on narrow `IXxxRepository` interface, not fat repository
- [ ] Delegate registered in a `DomainRegistry` subclass — not individual `Get.lazyPut`
- [ ] Delegate included in the registry's `delegates` list (for lifecycle)
- [ ] View binds via registry, not direct `Get.find<XDelegate>()`
- [ ] Unit test file created alongside delegate; mocks the ISP interface + `ActionQueue`
- [ ] No stateful `.obs` in extension files
- [ ] No `Get.find<>()` inside extension methods (use constructor injection via registry)
- [ ] Domain types do not extend `AppEvent` — use `ActionCompleted<T>` wrapper
- [ ] `flutter analyze` passes
- [ ] `bash scripts/check_architecture.sh` exits 0

---

## ELI5: What are the classes and their roles?

Think of the app as an office building. Each class is a type of person or room with one job.

**`BaseController` — the safety inspector**
Every worker in the building must sign in and sign out. `BaseController` holds the sign-in sheet (`workerObxVariables`, `_stateSubscriptions`). When a worker leaves (`onClose`), it makes sure they cancelled every subscription and disposed every reactive listener.

**`ReloadableController` — the badge checker**
Extends `BaseController`. Before starting work each day, it re-validates the session (your access badge). If the badge expired overnight, it re-authenticates. Subclasses pass their session tools in via constructor — it never goes hunting for them.

**`ControllerDelegate` — the specialist (plain Dart class)**
One delegate = one job. `SearchDelegate` only knows about search. `LabelDelegate` only knows about labels. It is a plain Dart class — not a GetxController, not a BaseController. Its manager (the `DomainRegistry`) tells it when to start (`init()`) and when to stop (`dispose()`). It never goes to `Get.find<>()` itself; the registry delivers its tools at the door. Max 200 LOC. Workers tracked via `trackWorker`, subscriptions via `trackSub`.

**`DomainRegistry` — the department manager**
Owns a set of delegates for one screen or department. It's the only layer (outside bindings) allowed to call `Get.find<>()` for infrastructure. It hands each delegate exactly the dependencies it needs via constructor. Drives the delegate lifecycle: calls `init()` on everyone when the manager starts, and `dispose()` in reverse order when the manager shuts down. Adding a new specialist = one `late final` line in the manager's roster.

**State Services (`SessionService`, `MailboxStateService`, `EmailListStateService`) — the shared whiteboards**
Information everyone needs (current session, selected mailbox, email list) lives here. Each whiteboard field has exactly ONE person allowed to erase and rewrite it — the name is in the comment above the field. Everyone else can only read. `SessionService` listens to the PA system for `SessionEstablishedEvent` and updates itself — login never touches it directly.

**`AppEventBus` — the PA system**
When something important happens (email moved, draft saved, composer opened), a delegate announces it on the PA system. Other delegates that care tune in. Crucially, domain results (`MarkAsEmailReadSuccess`) are wrapped in `ActionCompleted<T>` before being announced — the PA system only speaks "base language", so domain classes don't leak across layer boundaries.

**`ActionQueue` — the task dispatcher**
When a delegate needs async work, it hands a self-contained task slip (`DomainAction`) to the dispatcher. The dispatcher checks the session badge, runs the task, and announces the result (wrapped in `ActionCompleted<T>`) on the PA system. Tag uniqueness: if you submit "MarkAsRead:email123" twice in a row, the first one is cancelled before the second starts — no leaked subs. At logout, `cancelAll()` kills every in-flight task.

**`*_bindings.dart` — the front desk**
Registers the department managers and the permanent whiteboards. `Get.find<>()` appears only here and in `DomainRegistry` subclasses — never inside a delegate, controller, or view logic. One binding = one screen's wiring diagram.

**ISP repository interfaces (`IXRepository`) — the job description**
Instead of giving a delegate the entire `EmailRepository` (a 40-method fat class), we write a narrow job description. The delegate depends on the description, not the whole department. The existing fat repository silently implements all narrow interfaces — no data layer changes required.

**Extension methods (`on XController`) — the calculator on the desk**
A stateless helper that derives a value from state the controller already has. No memory, no `Get.find<>()`, no `.obs`. If it needs an external dependency, it is not an extension — it belongs in a delegate constructor.

---

## ELI5: How do the layers talk to each other?

There are exactly six ways things communicate. If you find a seventh, it is a bug.

```
┌──────────────────────────────────────────────────────────────┐
│                            VIEW                               │
│  reads state:  Get.find<DashboardDomainRegistry>().x.rxVar   │
│  triggers:     Get.find<DashboardDomainRegistry>().x.doX()   │
└──────────────────┬───────────────────────────────────────────┘
                   │  (1) reactive read + action call
                   ▼
┌──────────────────────────────────────────────────────────────┐
│       DOMAIN REGISTRY  (owns + drives delegate lifecycle)     │
│     ControllerDelegates — plain Dart, init()/dispose()        │
│  observes shared state via:  ever(_stateService.rx, ...)      │──(2) state service Rx ref
│  submits async work via:     _queue.submit(DomainAction)      │──(4) ActionQueue
│  announces events via:       eventBus.emit(...)               │──(3) EventBus
│  listens to events via:      eventBus.on<T>().listen          │
└──────────────────────────────────────────────────────────────┘
       (2)  ▲           (3) ▲ ▼            (4) ▼
            │               │          ┌─────────────────┐
  ┌──────────────────┐  ┌──────────┐   │  ActionQueue    │
  │  State Services  │  │ EventBus │   │  cancel-replace │
  │  (single writer) │  │  PA sys  │   │  cancelAll()    │──→ EventBus
  └──────────────────┘  └──────────┘   └─────────────────┘
            ▲ (5)                              (6) ▲
   Login emits SessionEstablishedEvent    onSessionReady/End
   SessionService subscribes              creates/deletes registries
```

**(1) View → Registry → Delegate** — the only way the UI gets data or sends actions.

**(2) State Services → Delegate constructor** — Rx references injected at registry creation.

**(3) Cross-feature announcements** — EventBus with wrapper events. Never state.

**(4) Delegate → ActionQueue → Domain** — async work via self-contained action objects.

**(5) Login → Session** — login emits `SessionEstablishedEvent`; `SessionService` owns its own update via its listener.

**(6) Session lifecycle** — explicit create/clear/delete via `onSessionReady` / `onSessionEnd`.

**The one rule that summarises all six:** data flows through state service Rx references; actions flow through ActionQueue; cross-feature side-effects flow through EventBus with wrapper events; session boundaries flow through the lifecycle protocol. Nothing else.

---

## Consequences

**Benefits:**
- Each concern is independently testable in isolation
- New features add zero coupling to existing controllers (OCP) — one `late final` line in the registry
- Dependencies are explicit and injectable (DIP)
- Controller LOC drops substantially — readable, reviewable
- Onboarding: new developers understand one delegate at a time
- `ActionQueue` eliminates per-delegate stream subscription boilerplate — submit and forget
- Wrapper events eliminate destructive-read race conditions from Rxn dispatch and keep domain types off the base layer
- State services decouple delegates from god controllers — delegates depend on services, not each other
- Session lifecycle protocol prevents stale state across login/logout cycles
- `DomainRegistry` lifecycle propagation eliminates the GetX hazard where `late final` delegates never receive `onInit`/`onClose`

**Costs:**
- Foundation is ~2 weeks before the first god controller is touched
- Per-controller extraction is effort-intensive — each Layer 2 phase is 1–2 weeks depending on size
- Views updated to reference delegates via registries — mass find-replace across many files
- `Get.find<>()` discipline enforced by `custom_lint` package (4 rules) + CI script

**Risks:**
- Stateful extension files have hidden interdependencies — extract one at a time
- Mock regeneration will temporarily break test files — fix immediately per phase
- Complex mixins with state may require their own delegates — evaluate before absorbing
- Rxn→wrapper-event migration must be atomic per delegate — partial migration leaves both systems active
- `DomainRegistry` lifecycle discipline depends on subclasses correctly listing delegates in the `delegates` override — forgetting one leaks workers. Mitigation: unit tests verify `dispose()` drops workers to zero for every registry
