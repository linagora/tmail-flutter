# 83. Patrol Web Integration Test — Migration Plan

Date: 2026-04-15

## Status

Proposed

## Related ADRs

- [ADR-0081](./0081-patrol-web-test-architecture.md) — Cross-platform test architecture (read first)
- [ADR-0082](./0082-patrol-web-test-migration-guide.md) — Impact analysis & implementation example

## Context

This ADR translates the migration steps from [ADR-0082](./0082-patrol-web-test-migration-guide.md) into a concrete PR plan. Each PR must leave the **mobile CI pipeline green**. Only the final PR is a breaking change.

---

## PR Plan

| PR | Type | Files changed | Files added | Mobile CI | Web CI |
|----|------|:---:|:---:|:---:|:---:|
| PR-1 | Addition | 0 | ~40 | ✅ unaffected | — |
| PR-2 | Refactor | ~82 | 0 | ✅ must pass | — |
| PR-3 | Addition | 0 | ~15 | ✅ unaffected | — |
| PR-4 | Addition | 0 | ~6 | ✅ unaffected | — |
| **PR-5** | **Breaking** | **~202** | 0 | ✅ must pass | ✅ first run |

PRs 1–4 are additive and can be merged in any order. **PR-5 must be a single atomic PR** — splitting it will break mobile CI.

---

## PR-1 — Abstract Robot Interfaces

Create `robots/abstract/` with one interface per existing robot class. No existing file is touched.

- **New files:** ~40 abstract interface files
- **Verify:** `flutter analyze` passes
- **Outcome:** Abstract contracts ready for implementations

---

## PR-2 — Move Robots to `robots/mobile/`

Rename all `robots/*.dart` → `robots/mobile/mobile_*.dart`. Add `implements AbstractXxxRobot` to each class. Extract shared base robots for methods identical across platforms. Update import paths in scenario files.

- **Moved files:** ~40 robots
- **Changed files:** ~80 scenarios + base files (import path updates only)
- **Verify:** `flutter analyze` passes + **mobile CI green** — confirms no logic was changed
- **Outcome:** Mobile robot layer clean; shared base robots ready for web robots to extend

---

## PR-3 — Web Robot Implementations

Create `robots/web/` with web-specific implementations for feature areas where the web UI genuinely differs. Robots with identical behavior across platforms are **not** duplicated here — both factories will return the same mobile class.

- **New files:** ~15 web robot files
- **Verify:** `flutter analyze` passes
- **Outcome:** Web interaction layer ready to be wired via factories

---

## PR-4 — Factories & Provider Files

Create the factory layer and the conditional export provider.

```
factories/
├── robot_factory.dart                 # Abstract factory interface
├── robot_factory_provider.dart        # Conditional export — never changes
├── mobile_robot_factory.dart
├── mobile_robot_factory_provider.dart
├── web_robot_factory.dart
└── web_robot_factory_provider.dart
```

- **New files:** ~6
- **Verify:** `flutter analyze` passes
- **Outcome:** Full factory graph in place; ready for `TestBase` to consume

---

## PR-5 (Atomic) — Base API + All Scenarios + All Test Files

> ⚠️ Do not split. Merging base changes without the scenario/test file updates breaks mobile CI immediately.

**`base/base_test_scenario.dart`** — accept `RobotFactory` via constructor, remove `RequiresLoginMixin`.

**`base/test_base.dart`** — import `robot_factory_provider.dart`, update `runPatrolTest` signature.

**All ~80 scenarios** — update constructor:
```dart
// Before                              // After
MyScenario(super.$);          →       MyScenario(super.$, super.robots);
```

**All ~120 test files** — update `scenarioBuilder`:
```dart
// Before                              // After
scenarioBuilder: ($) => ...   →       scenarioBuilder: ($, robots) => ...
```

**Delete** `mixin/requires_login_mixin.dart`.

The scenario and test file changes are mechanical and repetitive — suitable for bulk scripted refactoring followed by careful diff review.

- **Changed files:** ~202
- **Deleted files:** 1
- **Verify:** `flutter analyze` + **mobile CI green** + **web CI green** (first successful web run)
- **Outcome:** Architecture fully in place. Both platforms run from the same test files.

---

## Flow Summary

```
PR-1  abstract interfaces   → flutter analyze ✅
PR-2  move robots           → mobile CI ✅
PR-3  web robots            → flutter analyze ✅
PR-4  factories             → flutter analyze ✅
PR-5  base + all call sites → mobile CI ✅  web CI ✅
```

## Consequences

- PRs 1–4 are low-risk, reviewable asynchronously, and do not affect the team's daily workflow.
- PR-5 is large but entirely mechanical. Prioritize CI verification over line-by-line review.
- After PR-5, the migration is complete and the new architecture is the baseline for all future test work.
