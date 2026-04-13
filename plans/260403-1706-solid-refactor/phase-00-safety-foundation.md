## Phase 0: Safety Foundation

**Priority:** P1 | **Status:** pending | **Effort:** 2 days
**Blocking:** Non-blocking — all changes are additive or bug fixes. Land directly on `master`. Feature PRs unaffected.

> After this phase, the CI enforcement script is in place and new feature PRs are gated by current-baseline thresholds (not yet ratcheted). Any new code following the delegate pattern will pass automatically. The `ControllerDelegate` base class is available but has no subclasses yet — the first one lands as the pilot in Phase 2.

---

### Tasks

#### 0. Move `workerObxVariables` to `BaseController`

```dart
// lib/features/base/base_controller.dart
abstract class BaseController extends GetxController {
  // All ever()/debounce() workers MUST be registered here — never bare ever().
  final workerObxVariables = <Worker>[];

  @override
  void onClose() {
    for (final w in workerObxVariables) w.dispose();
    workerObxVariables.clear();
    super.onClose();
  }
}
```

Remove any duplicate `workerObxVariables` declarations from subclasses (god controllers often redeclare this — search and delete).

#### 0b. Fix `consumeState()` stream leak + deprecate

Fix the leak first (existing code still uses it), then mark deprecated. Phase 1 introduces `ActionQueue` as the replacement.

```dart
// Add field:
final _stateSubscriptions = <StreamSubscription>[];

// Replace consumeState():
@Deprecated('Use ActionQueue.submit() for new delegates. '
    'consumeState will be removed after all controllers migrate.')
void consumeState(Stream<Either<Failure, Success>> newStateStream) {
  _stateSubscriptions.add(newStateStream.listen(onData, onError: onError, onDone: onDone));
}

// Extend onClose():
@override
void onClose() {
  for (final sub in _stateSubscriptions) sub.cancel();
  _stateSubscriptions.clear();
  for (final w in workerObxVariables) w.dispose();
  workerObxVariables.clear();
  super.onClose();
}
```

The `@Deprecated` annotation produces analyzer warnings in any new code calling `consumeState()`. Existing code compiles without error. Removal happens after all controllers migrate to `ActionQueue`.

#### 0c. `ControllerDelegate` abstract base class

Introduce the canonical delegate base as a **plain Dart class** (not a `GetxController`, not a `BaseController`). Delegates are owned by their `DomainRegistry`, which drives their lifecycle deterministically. This avoids a known GetX hazard: when a delegate is stored as a `late final` inside a `GetxService`, GetX never calls `onInit`/`onClose` on the delegate — workers leak.

```dart
// lib/features/base/delegate/controller_delegate.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Base class for all controller delegates.
///
/// A delegate owns one feature's state and behavior. It is NOT a GetxController.
/// Its lifecycle is driven by its parent DomainRegistry via init() / dispose().
///
/// Delegates register GetX workers (ever/debounce/once/interval) via
/// [trackWorker] and event bus subscriptions via [trackSub]. Both are
/// disposed in [dispose], which the registry calls from its onClose().
abstract class ControllerDelegate {
  final _workers = <Worker>[];
  final _subs = <StreamSubscription>[];

  /// Register a GetX worker for automatic disposal.
  /// Usage: `trackWorker(ever(stateService.selectedMailbox, _onChange));`
  @protected
  Worker trackWorker(Worker worker) {
    _workers.add(worker);
    return worker;
  }

  /// Register a stream subscription for automatic disposal.
  /// Usage: `trackSub(eventBus.on<XEvent>().listen(_handle));`
  @protected
  StreamSubscription<T> trackSub<T>(StreamSubscription<T> sub) {
    _subs.add(sub);
    return sub;
  }

  /// Called once by the owning DomainRegistry in its onInit().
  /// Subclasses register workers and event subscriptions here.
  @mustCallSuper
  void init() {}

  /// Called once by the owning DomainRegistry in its onClose().
  /// Disposes all tracked workers and subscriptions.
  @mustCallSuper
  void dispose() {
    for (final w in _workers) w.dispose();
    for (final s in _subs) s.cancel();
    _workers.clear();
    _subs.clear();
  }
}
```

**Note:** This class has zero subclasses in Phase 0. The first subclass is the `NotificationDelegate` pilot in Phase 2. The CI lint rules below enforce that when subclasses appear, they follow the template (no bare `ever()`, no `Get.find<>()` inside delegate body).

#### 1. CI enforcement script — auto-discovering controller LOC gate

Create `scripts/check_architecture.sh`. Thresholds start at **current baselines** — CI never fails existing code; only prevents regressions beyond baseline.

**Key design — auto-discovery of god controllers.** Instead of hardcoding a list of controller paths, the script walks `lib/features/**/presentation/controller/*_controller.dart`, gates any controller at or above 700 LOC, and records its baseline. Baselines live in `scripts/controller_loc_baselines.txt` (one `path=loc` per line). A PR cannot increase any baselined controller's LOC. When a controller's LOC drops below 700, it is removed from the baseline file and no longer gated.

```bash
#!/bin/bash
set -e
FAIL=0

BASE_LOC=$(wc -l < lib/features/base/base_controller.dart | tr -d ' ')
BASE_MAX=${BASE_MAX:-647}   # ratcheted to 250 after Phase 2

echo "BaseController LOC: $BASE_LOC / $BASE_MAX"
[ "$BASE_LOC" -le "$BASE_MAX" ] || { echo "FAIL: BaseController $BASE_LOC LOC (max $BASE_MAX)"; FAIL=1; }

# ── Auto-discover controllers over 700 LOC and gate each against baseline ──
BASELINE_FILE="scripts/controller_loc_baselines.txt"
touch "$BASELINE_FILE"

# Build current snapshot: path=loc for every controller >= 700 LOC
CURRENT_GOD_CTRLS=$(find lib/features -type f -name '*_controller.dart' \
  -path '*/presentation/controller/*' \
  | while IFS= read -r f; do
      loc=$(wc -l < "$f" | tr -d ' ')
      if [ "$loc" -ge 700 ]; then
        echo "$f=$loc"
      fi
    done)

echo "=== God controllers (>=700 LOC) ==="
echo "$CURRENT_GOD_CTRLS"

# For each current god controller, check against stored baseline (or add it)
while IFS='=' read -r path loc; do
  [ -z "$path" ] && continue
  baseline=$(grep -E "^${path}=" "$BASELINE_FILE" | cut -d= -f2 || true)
  if [ -z "$baseline" ]; then
    echo "NEW GOD CONTROLLER: $path=$loc — adding to baseline"
    echo "$path=$loc" >> "$BASELINE_FILE"
  elif [ "$loc" -gt "$baseline" ]; then
    echo "FAIL: $path grew from $baseline to $loc LOC"
    FAIL=1
  fi
done <<< "$CURRENT_GOD_CTRLS"

# Prune baseline entries for controllers that dropped below 700 LOC
TMP_BASELINE=$(mktemp)
while IFS='=' read -r path loc; do
  [ -z "$path" ] && continue
  if [ -f "$path" ]; then
    current=$(wc -l < "$path" | tr -d ' ')
    if [ "$current" -ge 700 ]; then
      echo "$path=$current" >> "$TMP_BASELINE"
    else
      echo "GRADUATED: $path dropped to $current LOC — removed from baseline"
    fi
  fi
done < "$BASELINE_FILE"
mv "$TMP_BASELINE" "$BASELINE_FILE"

# ── Get.find outside bindings (ratcheted) ──
VIOLATIONS=$(grep -rn 'Get\.find' lib/features/ --include='*.dart' \
  | grep -v '_bindings\.dart' \
  | grep -v 'logout_mixin\.dart' \
  | grep -v '_test\.dart' \
  | wc -l | tr -d ' ')
VIOLATIONS_MAX=${VIOLATIONS_MAX:-207}
echo "Get.find outside bindings: $VIOLATIONS / $VIOLATIONS_MAX"
[ "$VIOLATIONS" -le "$VIOLATIONS_MAX" ] || { echo "FAIL: $VIOLATIONS Get.find calls outside bindings"; FAIL=1; }

# Delegate LOC (each <=200 LOC) — applies once delegates exist
while IFS= read -r f; do
  loc=$(wc -l < "$f" | tr -d ' ')
  if [ "$loc" -gt 200 ]; then
    echo "FAIL: delegate $f has $loc LOC (max 200)"
    FAIL=1
  fi
done < <(find lib -path '*/delegates/*.dart' 2>/dev/null)

# Bare ever() calls (ratcheted — must reach 0 over time)
BARE_EVER=$(grep -rn '^\s*ever(' lib/features/ --include='*.dart' \
  | grep -v 'workerObxVariables' \
  | grep -v 'trackWorker' \
  | grep -v '_test\.dart' \
  | wc -l | tr -d ' ')
BARE_EVER_MAX=${BARE_EVER_MAX:-23}
echo "Bare ever() calls: $BARE_EVER / $BARE_EVER_MAX"
[ "$BARE_EVER" -le "$BARE_EVER_MAX" ] || { echo "FAIL: $BARE_EVER bare ever() (max $BARE_EVER_MAX)"; FAIL=1; }

# Stateful extension files (.obs in extensions/ dir)
STATEFUL_EXTS=$(grep -rn '\.obs\b' lib/features/*/presentation/extensions/ --include='*.dart' 2>/dev/null | wc -l | tr -d ' ')
echo "Stateful .obs vars in extension files: $STATEFUL_EXTS"
[ "$STATEFUL_EXTS" -eq 0 ] || { echo "FAIL: $STATEFUL_EXTS .obs vars in extension files"; FAIL=1; }

# Cross-feature datasource injection in bindings
CROSS_DS=0
for feature in mailbox email thread composer; do
  other_features=$(echo "mailbox email thread composer" | tr ' ' '\n' | grep -v "^${feature}$")
  while IFS= read -r other; do
    count=$(grep -rn "${other^}DataSource\|${other}DataSource" \
      lib/features/${feature}/presentation/bindings/ --include='*_bindings.dart' 2>/dev/null | wc -l | tr -d ' ')
    if [ "$count" -gt 0 ]; then
      echo "WARN: ${feature} bindings inject ${other} DataSource ($count occurrences)"
      CROSS_DS=$((CROSS_DS + count))
    fi
  done <<< "$other_features"
done
echo "Cross-feature datasource injections in bindings: $CROSS_DS (target: 0)"
[ "$CROSS_DS" -eq 0 ] || { echo "FAIL: $CROSS_DS cross-feature DataSource injections in bindings"; FAIL=1; }

# XBindings().dependencies() calls outside bindings (ratcheted)
BINDING_VIOLATIONS=$(grep -rn '\.dependencies()' lib/features/ --include='*.dart' \
  | grep -v '_bindings\.dart' \
  | grep -v 'inject[A-Z]' \
  | grep -v 'fcm_message_controller\.dart' \
  | grep -v 'main_entry\.dart' \
  | wc -l | tr -d ' ')
BINDING_VIOLATIONS_MAX=${BINDING_VIOLATIONS_MAX:-36}
echo "XBindings().dependencies() violations: $BINDING_VIOLATIONS / $BINDING_VIOLATIONS_MAX"
[ "$BINDING_VIOLATIONS" -le "$BINDING_VIOLATIONS_MAX" ] || { echo "FAIL: $BINDING_VIOLATIONS binding calls outside bindings (max $BINDING_VIOLATIONS_MAX)"; FAIL=1; }

# Binding file LOC (each <=60 LOC — skipped until Phase 2 bindings split)
if [ -z "$SKIP_BINDING_CHECK" ]; then
  while IFS= read -r f; do
    loc=$(wc -l < "$f" | tr -d ' ')
    if [ "$loc" -gt 60 ]; then
      echo "WARN: binding $f has $loc LOC (target <=60)"
    fi
  done < <(find lib -name '*_bindings.dart' 2>/dev/null)
fi

# ReloadableController — must have zero Get.find (after Phase 2)
RELOAD_VIOLATIONS=$(grep -c 'Get\.find' lib/features/base/reloadable/reloadable_controller.dart 2>/dev/null || echo 0)
RELOAD_MAX=${RELOAD_MAX:-0}
echo "ReloadableController Get.find: $RELOAD_VIOLATIONS / $RELOAD_MAX"
[ "$RELOAD_VIOLATIONS" -le "$RELOAD_MAX" ] || { echo "FAIL: $RELOAD_VIOLATIONS Get.find in ReloadableController"; FAIL=1; }

# Domain Success/Failure extending AppEvent (must be 0 — use wrapper events instead)
DOMAIN_APPEVENT=$(grep -rn 'extends AppEvent' lib/features/ --include='*.dart' 2>/dev/null \
  | grep -v 'lib/features/base/event_bus/' \
  | wc -l | tr -d ' ')
echo "Domain types extending AppEvent: $DOMAIN_APPEVENT (target: 0)"
[ "$DOMAIN_APPEVENT" -eq 0 ] || { echo "FAIL: $DOMAIN_APPEVENT domain types extend AppEvent; use wrapper events"; FAIL=1; }

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "PASS: All architecture checks passed."
else
  echo "FAIL: Architecture checks failed."
  exit 1
fi
```

**Commit `scripts/controller_loc_baselines.txt` as part of this phase.** Bootstrap by running the script once — it auto-populates the file with every controller currently ≥700 LOC.

Add to CI (GitHub Actions):

```yaml
- name: Architecture checks
  run: |
    BASE_MAX=647 VIOLATIONS_MAX=207 BINDING_VIOLATIONS_MAX=36 BARE_EVER_MAX=23 RELOAD_MAX=20 \
    bash scripts/check_architecture.sh
```

**Ratchet schedule** — update CI YAML at the end of each phase:

| After Phase | `BASE_MAX` | `VIOLATIONS_MAX` | `BINDING_VIOLATIONS_MAX` | `BARE_EVER_MAX` | `RELOAD_MAX` |
|---|---|---|---|---|---|
| 0 | 647 | 207 | 36 | 23 | 20 |
| 2 | **250** | ratchet downward as delegates land | **0** | ratchet downward | **0** |
| N (per controller) | 250 | further ratchet | 0 | further ratchet | 0 |

The controller LOC gate is ratcheted automatically via the baseline file — no YAML change needed.

#### 2. Custom lint rules via `custom_lint` (parallel with Task 1)

Create `tools/tmail_lint/` with 4 custom lint rules. IDE warnings — complement the shell script.

```yaml
# tools/tmail_lint/pubspec.yaml
name: tmail_lint
dependencies:
  custom_lint_builder: ^0.6.0
  analyzer: ^6.0.0
```

```yaml
# analysis_options.yaml (root) — add:
analyzer:
  plugins:
    - custom_lint
custom_lint:
  rules:
    - avoid_bare_ever
    - no_get_find_outside_bindings
    - no_binding_call_outside_bindings
    - no_appevent_domain_inheritance
```

Rules:

- **`avoid_bare_ever`** — ERROR if `ever()` called without `workerObxVariables.add(...)` or `trackWorker(...)`.
- **`no_get_find_outside_bindings`** — ERROR if `Get.find<>()` appears in non-binding files. Whitelist: `logout_mixin.dart`, `*_test.dart`, `controller_delegate.dart`, `*_domain_registry.dart`.
- **`no_binding_call_outside_bindings`** — WARN if `XBindings().dependencies()` appears outside a `*_bindings.dart` file and not inside a method named `inject*`. Whitelist: `fcm_message_controller.dart`, `main_entry.dart`.
- **`no_appevent_domain_inheritance`** — ERROR if a domain Success/Failure class `extends AppEvent`. Use `ActionCompleted<T>` or named wrapper events.

---

### Execution Order

1. `consumeState()` stream fix (Task 0b)
2. `workerObxVariables` → `BaseController` (Task 0)
3. `ControllerDelegate` abstract base class (Task 0c)
4. CI script + controller LOC baseline file + CI YAML (Task 1) **[parallel with Task 2]**
5. `custom_lint` package (Task 2) **[parallel with Task 1]**

---

### Success Criteria

- [ ] `workerObxVariables` in `BaseController`; duplicate removed from subclasses
- [ ] `consumeState()` uses `_stateSubscriptions`; list cancelled in `onClose()`
- [ ] `@Deprecated` annotation on `consumeState()` produces analyzer warning in new call sites
- [ ] `ControllerDelegate` base class created at `lib/features/base/delegate/controller_delegate.dart`; zero subclasses yet
- [ ] `scripts/check_architecture.sh` created and exits 0 with Phase 0 baselines
- [ ] `scripts/controller_loc_baselines.txt` committed, auto-populated from current state
- [ ] CI YAML updated with architecture check step (`BASE_MAX=647`, `VIOLATIONS_MAX=207`, `BINDING_VIOLATIONS_MAX=36`, `BARE_EVER_MAX=23`)
- [ ] `custom_lint` package (`tools/tmail_lint/`) created with 4 rules; `flutter analyze` reports lint violations
- [ ] `dart run build_runner build --delete-conflicting-outputs` + `flutter test` pass
