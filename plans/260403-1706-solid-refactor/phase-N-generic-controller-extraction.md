## Phase N: Generic Per-Controller Extraction Protocol (Template)

**Priority:** P2 | **Status:** template (not actionable) | **Effort:** per controller
**Depends on:** Phase 2 complete, pilot delegate shipped
**Blocking:** Non-blocking — runs in a git worktree. `master` is always open for feature work.

> **This file is a template.** When a god controller is chosen for decomposition, copy this file to `phase-NN-<controller-name>-decomposition.md`, replace placeholders, and start work. Do NOT edit this template in place for a specific controller.
>
> **Ordering rule:** Tackle god controllers smallest LOC first. Earlier controllers validate the pattern and tooling on lower-risk targets before touching the largest.

---

### Copy checklist (before starting a per-controller phase)

- [ ] Copy this file to `phase-NN-<controller>-decomposition.md`
- [ ] Update the header (priority, effort estimate, branch name)
- [ ] Fill in the **controller baseline** section (LOC, deps, extensions, mixins)
- [ ] Fill in the **domain boundary table** with every Rx var and extension
- [ ] Fill in the **Rxn dispatch inventory** if this controller has `Rxn<UIAction>` streams
- [ ] Name each delegate you plan to extract and list its coupling level
- [ ] Pre-create a git worktree: `git worktree add ../tmail-<controller>-refactor refactor/solid-<controller>`
- [ ] Announce the phase on the team channel (file ownership + estimated duration)

---

### Controller baseline (fill in per controller)

| Metric | Current | Target |
|--------|---------|--------|
| Controller LOC | TBD | ≤700 |
| Constructor deps | TBD | ≤10 |
| Field-level `Get.find` | TBD | 0 |
| Extension files | TBD | ≤ (controller/3) |
| Mixins (stateful) | TBD | 0 |
| Rxn dispatch streams | TBD | 0 |
| Test files mocking the controller | TBD | 0 (migrated per delegate) |

---

### Day 0: Discovery (before any extraction)

#### 0a. Domain boundary table

Inventory every extension file, mixin, and Rx var. For each, record the primary domain, which Rx vars it reads/writes, cross-domain dependencies, and the delegate that will own it.

| Extension / Mixin / Rx group | Primary domain | Rx vars read | Rx vars written | Cross-domain deps | Target delegate |
|---|---|---|---|---|---|
| *fill in* | | | | | |

#### 0b. Rxn dispatch inventory (if applicable)

For every `Rxn<UIAction>` stream on the controller, list the action subtypes, their consumers, and the typed wrapper event that will replace each.

| Rxn stream | Action type | Consumer | Replacement event |
|---|---|---|---|
| *fill in* | | | |

#### 0c. Satellite controller audit

Identify any controller under `lib/features/` that calls `Get.find<ThisGodController>()`. For each caller, decide:

- **Re-use as-is:** the caller is already focused on one domain; swap its `Get.find` for `Get.find<XDomainRegistry>().y` or a state service read.
- **Extract residual:** the caller leaks state back into the god controller; extract that state into the caller first.

Record the decision here. Satellite migration happens incrementally as delegates become available.

#### 0d. Characterization tests

Copy the Phase 1 template to `test/features/<feature>/characterization/<controller>_characterization_test.dart`. Write one test per method you plan to extract. Run green against the current god controller before touching anything. These are the regression net.

---

### Day N: Delegate extraction loop (repeat per delegate, lowest coupling first)

For each delegate identified in the domain boundary table:

1. **Create the narrow ISP interface.** `lib/features/<feature>/domain/repositories/i_<name>_repository.dart`. Existing fat repository silently implements it — no data-layer changes.

2. **Create the delegate file.** Subclass `ControllerDelegate`. Constructor takes `ActionQueue`, state services it needs, `AppEventBus` (if it listens), and the ISP repository. Zero `Get.find` in the body. Use `trackWorker` and `trackSub` for all workers and subscriptions.

3. **Add a forwarding stub in the god controller.** Methods on the controller delegate to the new delegate via `Get.find<XDomainRegistry>().y`. Keeps the codebase green while callers migrate.

4. **Migrate Rxn action types owned by this delegate to typed wrapper events.**
   - Create a typed event class (or reuse `ActionCompleted<XSuccess>`)
   - Replace `dispatchXxxAction(ActionType())` calls with `eventBus.emit(...)`
   - In consuming controllers, replace `_registerObxStreamListener` cases with `eventBus.on<T>().listen(...)` tracked in `workerObxVariables` or `trackSub`
   - When all types for a Rxn stream are migrated, delete the Rxn field and the `_registerObxStreamListener` method

5. **Create or extend the domain registry.** If this is the first delegate for the controller, create `lib/features/<feature>/presentation/registries/<feature>_domain_registry.dart` subclassing `DomainRegistry`. Add the delegate as a `late final` field and include it in `delegates`. Register the registry in the feature binding.

6. **Update views.** Views read state and trigger actions via `Get.find<XDomainRegistry>().y`. No views reference `Get.find<XDelegate>()` directly.

7. **Move state into state services where applicable.** If the delegate owns shared state (e.g. selected mailbox), update the state service's single-writer doc to name this delegate.

8. **Migrate tests inline.** For every test that previously mocked the god controller:
   - Rename to match the delegate
   - Mock the ISP interface and `ActionQueue` instead of the fat repository and controller
   - Assert on `ActionCompleted<XSuccess>` wrapper events (or named events) instead of on Rxn dispatch

9. **Run the build gate.**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   flutter analyze
   flutter test
   bash scripts/check_architecture.sh
   ```
   All four must exit 0.

10. **Delete the forwarding stub + absorbed extension files** from the god controller.

11. **Commit — one delegate per commit.** Message format: `refactor(<feature>): extract <Name>Delegate`.

12. **Ratchet CI thresholds** for this controller's baseline entry in `scripts/controller_loc_baselines.txt`. The auto-discovery gate picks this up automatically.

---

### Cross-feature decoupling (runs incrementally alongside delegate extraction)

As delegates become available:

- Replace `Get.find<ThisGodController>()` calls in satellite controllers with:
  - `Get.find<SessionService>()` for session/account
  - `Get.find<MailboxStateService>()` or `Get.find<EmailListStateService>()` for shared Rx state
  - `Get.find<XDomainRegistry>().y` for domain actions

- Convert every bare `ever()` in satellite controllers to `workerObxVariables.add(ever(...))`.

- When the controller's Rxn dispatch streams are fully migrated, delete the fields and the `_registerObxStreamListener` methods. Confirm `scripts/check_architecture.sh` passes.

---

### Session lifecycle integration (runs once per session-scoped registry)

If this controller's domain registry is session-scoped (not route-scoped), wire it into the session lifecycle protocol:

```dart
// Implementation lives in the login / logout flow, not in a delegate:
void onSessionReady(Session session, AccountId accountId) {
  Get.find<AppEventBus>().emit(SessionEstablishedEvent(session, accountId));
  // SessionService reacts via its own listener — no direct assignment.

  // Session-scoped registries:
  Get.put(XDomainRegistry(
    Get.find<ActionQueue>(),
    Get.find<AppEventBus>(),
    // ...
  ));
}

void onSessionEnd() {
  Get.find<AppEventBus>().emit(const SessionEndedEvent());
  // SessionService + state services react to SessionEndedEvent and clear.

  Get.find<ActionQueue>().cancelAll();

  Get.delete<XDomainRegistry>(); // triggers dispose() on every delegate
}
```

Lifecycle tier table (reference):

| Tier | Components | Created | Destroyed |
|---|---|---|---|
| **Boot** (permanent) | AppEventBus, ActionQueue, SessionService, state services, ViewContextService, AuthService, CacheService, UIService | `main_bindings.dart` | Never (cleared on logout via `SessionEndedEvent`) |
| **Session** | Session-scoped domain registries | `onSessionReady()` | `onSessionEnd()` |
| **Route** | Route-scoped domain registries, screen controllers | Route binding | Route pop |
| **Widget** | Micro-controllers (e.g. `RichTextWebController`) | Widget build | Widget dispose |

---

### Operation lifetime reclassification (case-by-case)

If this controller owns work that outlives its scope, reclassify:

| Duration | Owner | Example |
|---|---|---|
| Instant (<1s) | Delegate | Toggle star, mark read |
| Short (1–5s) | Delegate + toast on fail | Move to folder |
| Long (>5s, user may navigate) | Session-lifetime service | Download, send email, empty trash |
| Background (survives app) | Platform service (WorkManager/FCM) | FCM sync, sending queue |

Reclassify long-running controllers (e.g. `DownloadController`, `SendingQueueController`) as session-lifetime `GetxService` instances. Move their `Get.put` from route binding to `onSessionReady`. Views observe via `Get.find<XService>().state` — independent of any screen controller.

---

### Verification gate (per delegate)

After every delegate extraction:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
bash scripts/check_architecture.sh
```

If any of the four fails, revert the extraction and debug. Never comment out a test to get green.

---

### Per-controller success criteria (fill in baseline numbers)

- [ ] Day 0 domain boundary table complete (every extension + Rx var mapped)
- [ ] Day 0 Rxn dispatch inventory complete (if controller has Rxn streams)
- [ ] Day 0 satellite audit complete (each caller has a re-use or extract decision)
- [ ] Day 0 characterization tests pass against current god controller
- [ ] Controller LOC ≤ 700 (ratchet target)
- [ ] Delegates created: (N) — each ≤200 LOC
- [ ] Domain registry created; `init()`/`dispose()` lifecycle tested
- [ ] All delegates use `ControllerDelegate` base class (not `BaseController`)
- [ ] All delegates use `ActionQueue.submit()` — zero new `consumeState()` calls
- [ ] All Rxn dispatch streams owned by this controller deleted (if any existed)
- [ ] Satellite `Get.find<ThisGodController>()` references = 0
- [ ] Bare `ever()` in new code = 0
- [ ] ISP repository interfaces created: one per delegate
- [ ] Inline test migration complete; no test mocks the god controller
- [ ] `scripts/controller_loc_baselines.txt` updated or entry removed (if LOC dropped below 700)
- [ ] `bash scripts/check_architecture.sh` exits 0
- [ ] `flutter analyze` + `flutter test` pass
- [ ] Smoke test on web + mobile passes
- [ ] One commit per delegate (clean history)

---

### When all god controllers are decomposed

Run a final sweep phase (documented JIT when the time comes):

- Update `docs/system-architecture.md` with the new architecture (delegates, registries, state services, EventBus catalog)
- Update `docs/adr/0079-solid-refactor-controller-decomposition.md` with the "Consequences: Actual" section: real metrics achieved, patterns that worked, tech debt that remains
- Delete `consumeState()` from `BaseController` once all legacy callers are gone
- Verify `BASE_MAX=250`, `VIOLATIONS_MAX=0`, `BARE_EVER_MAX=0`, `BINDING_VIOLATIONS_MAX=0`, `RELOAD_MAX=0`
- Verify `scripts/controller_loc_baselines.txt` is empty (no controller exceeds 700 LOC)

This final sweep is not pre-scheduled — it happens after the last Layer 2 phase lands.
