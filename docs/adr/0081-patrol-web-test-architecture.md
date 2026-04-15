# 81. Patrol Web Integration Test — Architecture & Test Authoring

Date: 2026-04-15

## Status

Proposed

## Related ADRs

- [ADR-0053](./0053-patrol-integration-test.md) — Patrol for mobile integration testing (foundation)
- [ADR-0080](./0080-patrol-web-integration-test-setup.md) — Web test setup & execution
- [ADR-0082](./0082-patrol-web-test-migration-guide.md) — Migration guide & implementation example
- [ADR-0083](./0083-patrol-web-test-migration-plan.md) — PR-by-PR migration plan

## Context

[ADR-0053](./0053-patrol-integration-test.md) established a three-layer architecture — **Test → Scenario → Robot** — for mobile. Extending to web with the POC approach revealed three problems:

- **Robot classes mix platform logic** — `ComposerRobot` has both `addContent()` (mobile) and `addContentWeb()` (web), violating SRP.
- **Scenarios are duplicated** — same business flow written twice for each platform, violating DRY.
- **Closed to extension** — adding a new platform requires modifying existing robot classes, violating OCP.

## Decision

Apply **Abstract Factory** + **Interface Segregation** to separate:
- **WHAT** — Business flow (Scenario): shared across all platforms.
- **HOW** — UI interaction (Robot): implemented per platform.

Platform selection uses **Dart conditional exports** — no logic class ever contains a platform `if/else` branch.

### Architecture

```
Test File (one file per scenario)
    │
    ▼
TestBase.runPatrolTest()
    ├── auto-applies platform tag (web / mobile)
    └── calls createRobotFactory($)
              ↑ resolved at compile time via conditional export
              ├── MobileRobotFactory  (default)
              └── WebRobotFactory     (dart.library.html)
    │  injects into
    ▼
BaseTestScenario(PatrolIntegrationTester $, RobotFactory robots)
    │  uses
    ▼
Abstract Robot Interfaces     ← Scenarios depend only on these
    ├── AbstractComposerRobot
    └── AbstractThreadRobot
         │  implemented by
         ▼
Concrete Robots
    ├── mobile/MobileComposerRobot
    └── web/WebComposerRobot
```

`TestBase` is the only class that calls `createRobotFactory()`. Scenarios and test files never reference any platform-specific class.

### Folder Structure

```
integration_test/
├── robots/
│   ├── abstract/          # Interfaces — one per feature area
│   ├── mobile/            # Mobile implementations
│   └── web/               # Web implementations (only where UI differs)
├── factories/
│   ├── robot_factory.dart
│   ├── robot_factory_provider.dart        # Conditional export — never changes
│   ├── mobile_robot_factory.dart
│   ├── mobile_robot_factory_provider.dart
│   ├── web_robot_factory.dart
│   └── web_robot_factory_provider.dart
├── scenarios/             # All shared — no web_/mobile_ prefix
└── tests/                 # One file per scenario — no platform subfolders
```

### Key Design Decisions

**1. Conditional export — the only platform-branching point**

```dart
// factories/robot_factory_provider.dart  ← this file never changes
export 'mobile_robot_factory_provider.dart'
    if (dart.library.html) 'web_robot_factory_provider.dart';

// Each provider exports one function with the same name
RobotFactory createRobotFactory(PatrolIntegrationTester $) => WebRobotFactory($);
```

Adding a new platform: create a provider file + factory + robot implementations. **No existing file is modified.**

**2. TestBase resolves and injects the factory**

```dart
// base/test_base.dart
import '../factories/robot_factory_provider.dart';

void runPatrolTest({
  required String description,
  required BaseTestScenario Function(PatrolIntegrationTester $, RobotFactory robots) scenarioBuilder,
  List<TestTags> tags = const [],
}) {
  final resolvedTags = [
    ...tags.map((t) => t.name),
    kIsWeb ? TestTags.web.name : TestTags.mobile.name,  // auto-applied
  ];
  patrolTest(description, tags: resolvedTags, ($) async {
    await setupTest();
    await scenarioBuilder($, createRobotFactory($)).execute();
  });
}
```

**3. Scenario receives factory via DI — zero platform knowledge**

```dart
abstract class BaseTestScenario extends BaseScenario {
  final RobotFactory robots;
  const BaseTestScenario(super.$, this.robots);

  @override
  Future<void> execute() async {
    await robots.loginRobot().login(...);
    await runTestLogic();
  }
}
```

**4. Test file — one file for all platforms**

```dart
void main() {
  TestBase().runPatrolTest(
    description: 'Send email',
    scenarioBuilder: ($, robots) => SendEmailScenario($, robots),
  );
}
```

**5. Robot reuse — when behavior is identical, both factories return the same class**

```dart
// WebRobotFactory — reuse mobile robot when no UI difference
@override AbstractThreadRobot threadRobot() => MobileThreadRobot($);
```

### How to Add a Test for a New Feature

1. Add `UiKey`s to all platform widget variants in `lib/features/base/model/ui_keys.dart`.
2. Define an abstract robot interface in `robots/abstract/` if one does not exist for the feature area.
3. Implement the robot in `robots/mobile/` and `robots/web/`. Use a shared base class for methods identical across platforms. Reuse the same class in both factories if behavior is entirely identical.
4. Register the robot in `MobileRobotFactory` and `WebRobotFactory`.
5. Write one scenario in `scenarios/` using abstract robots only.
6. Write one test file in `tests/`: `scenarioBuilder: ($, robots) => MyScenario($, robots)`.

### SOLID Alignment

| Principle | How it applies |
|-----------|---------------|
| **S** | Robot: UI interaction. Scenario: business flow. Factory: object creation. `TestBase`: lifecycle + wiring. |
| **O** | New platform: add provider + factory + robots. No existing class modified. |
| **L** | `WebRobotFactory` and `MobileRobotFactory` are substitutable through `RobotFactory`. |
| **I** | Each robot interface is scoped to its feature area. Split `RobotFactory` if it exceeds ~15 methods. |
| **D** | Scenarios depend on `RobotFactory` (abstraction). `TestBase` imports `createRobotFactory` from provider. |

## Consequences

- Scenarios and test files are written exactly once — no platform variants.
- No logic class contains a platform `if/else` — platform branching is a Dart export declaration.
- Adding a new platform touches zero existing files.
- Platform tags are auto-applied by `TestBase`.
- Migration is a one-time breaking change — see [ADR-0082](./0082-patrol-web-test-migration-guide.md) and [ADR-0083](./0083-patrol-web-test-migration-plan.md).
