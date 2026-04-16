# 82. Patrol Web Integration Test — Migration Guide & Implementation Example

Date: 2026-04-15

## Status

Proposed

## Related ADRs

- [ADR-0053](./0053-patrol-integration-test.md) — Patrol for mobile integration testing (foundation)
- [ADR-0080](./0080-patrol-web-integration-test-setup.md) — Web test setup & execution
- [ADR-0081](./0081-patrol-web-test-architecture.md) — Cross-platform test architecture (read first)
- [ADR-0083](./0083-patrol-web-test-migration-plan.md) — PR-by-PR migration plan

## Context

[ADR-0081](./0081-patrol-web-test-architecture.md) defines the target architecture. This ADR covers the impact on existing mobile tests and provides a concrete implementation example. For the PR breakdown and sequencing, see [ADR-0083](./0083-patrol-web-test-migration-plan.md).

---

## Impact on Existing Mobile Tests

The migration changes two public APIs in `base/`:

| Location | Before | After |
|----------|--------|-------|
| Test file | `scenarioBuilder: ($) => MyScenario($)` | `scenarioBuilder: ($, robots) => MyScenario($, robots)` |
| Scenario constructor | `MyScenario(super.$)` | `MyScenario(super.$, super.robots)` |
| Login | `RequiresLoginMixin` | `robots.loginRobot().login()` in `BaseTestScenario` |

### Estimated scope

| Category | Action | Count |
|----------|--------|-------|
| `scenarios/**/*.dart` | Update constructor | ~80 files |
| `tests/**/*.dart` | Update `scenarioBuilder` | ~120 files |
| `robots/*.dart` | Move to `robots/mobile/`, add interface | ~40 files |
| `robots/abstract/*.dart` | New interfaces | ~40 new files |
| `robots/web/*.dart` | New web implementations | ~15 new files |
| `factories/*.dart` | New factory + provider files | ~6 new files |
| `base/` | Update `TestBase` + `BaseTestScenario` | 2 files |

### What is NOT affected

- `ScenarioUtilsMixin` — provisioning helpers are unchanged.
- `base_scenario.dart`, `core_robot.dart` — unchanged.
- Robot interaction logic — moved, not rewritten.
- CI pipeline scripts — unchanged.

### Side effects

- Mobile CI breaks if the base API change ships without the scenario/test file updates. The final PR must be **atomic** — see [ADR-0083](./0083-patrol-web-test-migration-plan.md).
- `RequiresLoginMixin` is deleted once migration is complete.
- Robots identical across platforms (e.g. `SearchRobot`) need an abstract interface but no web variant.

---

## Implementation Example: Send Email

This example shows the full implementation of a cross-platform test under the new architecture.

### 1. UIKeys — applied to all platform widget variants

```dart
// lib/features/base/model/ui_keys.dart
class UiKeys {
  static const String composeEmailButton = 'composeEmailButton';
  static const String sendEmailButton = 'sendEmailButton';
}
```

Apply the same key to mobile toolbar, web toolbar, and tablet toolbar widgets.

### 2. Abstract robot interfaces

```dart
// robots/abstract/abstract_composer_robot.dart
abstract class AbstractComposerRobot {
  Future<void> addRecipient(PrefixEmailAddress prefix, String email);
  Future<void> addSubject(String subject);
  Future<void> addContent(String content);
  Future<void> send();
}
```

### 3. Shared base + platform implementations

Methods identical across platforms go in a shared base to avoid duplication. The base class can live in its own file (e.g. `robots/mobile/base_composer_robot.dart`) or alongside the mobile implementation:

```dart
// robots/mobile/base_composer_robot.dart
abstract class BaseComposerRobot extends CoreRobot implements AbstractComposerRobot {
  BaseComposerRobot(super.$);

  // Identical on all platforms — defined once here
  @override Future<void> send() async =>
    $(const ValueKey(UiKeys.sendEmailButton)).tap();

  @override Future<void> addRecipient(...) async { ... }
  @override Future<void> addSubject(...) async { ... }
}

class MobileComposerRobot extends BaseComposerRobot {
  MobileComposerRobot(super.$);

  @override
  Future<void> addContent(String content) async {
    // Navigate InAppWebView widget tree
    ComposerController? controller;
    await $(ComposerView).which<ComposerView>((w) {
      controller = w.controller; return true;
    }).$(MobileEditorView).$(HtmlEditor).$(InAppWebView).tap();
    await controller!.htmlEditorApi!.insertHtml('$content <br><br>');
  }
}

// robots/web/web_composer_robot.dart
class WebComposerRobot extends BaseComposerRobot {
  WebComposerRobot(super.$);

  @override
  Future<void> addContent(String content) async {
    await $(WebEditorWidget).tap();
    await $.platformAutomator.web.enterText(
      WebSelector(cssOrXpath: 'div.note-editable'),
      iframeSelector: WebSelector(cssOrXpath: 'iframe'),
      text: content,
    );
  }
}
```

`ThreadRobot` has no UI difference — one class reused by both factories:

```dart
class MobileThreadRobot extends CoreRobot implements AbstractThreadRobot {
  @override Future<void> openComposer() async =>
    $(const ValueKey(UiKeys.composeEmailButton)).$(InkWell).tap();
}
```

### 4. Factory registration

```dart
// factories/web_robot_factory.dart
class WebRobotFactory implements RobotFactory {
  final PatrolIntegrationTester $;
  WebRobotFactory(this.$);

  @override AbstractComposerRobot composerRobot() => WebComposerRobot($);
  @override AbstractThreadRobot threadRobot() => MobileThreadRobot($);   // reused
  @override AbstractLoginRobot loginRobot() => WebLoginRobot($);
}
```

### 5. Scenario — written once

```dart
// scenarios/composer/send_email_scenario.dart
class SendEmailScenario extends BaseTestScenario {
  const SendEmailScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    await robots.threadRobot().openComposer();
    await robots.composerRobot().addRecipient(PrefixEmailAddress.to,
      const String.fromEnvironment('BASIC_AUTH_EMAIL'));
    await robots.composerRobot().addSubject('Send email test');
    await robots.composerRobot().addContent('Hello from Patrol');
    await robots.composerRobot().send();
    await expectViewVisible(
      $(find.text(AppLocalizations().message_has_been_sent_successfully)));
  }
}
```

### 6. Test file — one file, all platforms

```dart
// tests/composer/send_email_test.dart
void main() {
  TestBase().runPatrolTest(
    description: 'Send email',
    scenarioBuilder: ($, robots) => SendEmailScenario($, robots),
  );
}
```

```bash
# Mobile
patrol test -t integration_test/tests/composer/send_email_test.dart \
  --device=android

# Web
patrol test -t integration_test/tests/composer/send_email_test.dart \
  --device=chrome --web-headless=true
```

Same file. Same scenario. Factory resolved automatically per platform via `kIsWeb` — `--device` already determines the target, so `--tags` is not required for routing.

---

## Handling Platform-Only Features

Some features exist only on web (e.g., a browser-specific upload flow) or only on mobile (e.g., deep links). Using `@Tags` annotations works but is error-prone — developers can easily forget to add them. Instead, platform constraints are encoded **inside `runPatrolTest()`** so the test skips itself automatically.

### `TestPlatform` enum + `platforms` parameter

```dart
// base/test_platform.dart
enum TestPlatform { mobile, web }
```

`runPatrolTest()` accepts an optional `platforms` parameter (defaults to both):

```dart
// base/test_base.dart
void runPatrolTest({
  required String description,
  required ScenarioBuilder scenarioBuilder,
  List<TestPlatform> platforms = const [TestPlatform.mobile, TestPlatform.web],
}) {
  final currentPlatform = kIsWeb ? TestPlatform.web : TestPlatform.mobile;
  patrolTest(
    description,
    skip: !platforms.contains(currentPlatform),
    ($) async {
      final robots = kIsWeb ? WebRobotFactory($) : MobileRobotFactory($);
      await scenarioBuilder($, robots).run();
    },
  );
}
```

### Developer usage

```dart
// Web-only — skips automatically on mobile
void main() {
  TestBase().runPatrolTest(
    description: 'Drag and drop upload',
    platforms: [TestPlatform.web],
    scenarioBuilder: ($, robots) => DragDropUploadScenario($, robots),
  );
}

// Mobile-only — skips automatically on web
void main() {
  TestBase().runPatrolTest(
    description: 'Deep link handling',
    platforms: [TestPlatform.mobile],
    scenarioBuilder: ($, robots) => DeepLinkScenario($, robots),
  );
}

// Runs on both — omit platforms (default)
void main() {
  TestBase().runPatrolTest(
    description: 'Send email',
    scenarioBuilder: ($, robots) => SendEmailScenario($, robots),
  );
}
```

No `@Tags`, no `--exclude-tags` in CI — each test knows where it belongs.

### CI commands (simplified)

```bash
# Mobile — runs all tests; platform-only tests skip themselves
patrol test --device=android

# Web — runs all tests; platform-only tests skip themselves
patrol test --device=chrome --web-headless=true
```

### Unsupported robot in the factory

As a second safety net, if a web-only robot is accidentally called on mobile (e.g. shared scenario logic), the mobile factory fails fast:

```dart
// factories/mobile_robot_factory.dart
@override
AbstractUploadRobot uploadRobot() =>
    throw UnsupportedError('Web upload is not supported on mobile');

// factories/web_robot_factory.dart
@override
AbstractUploadRobot uploadRobot() => WebUploadRobot($);
```

### Summary

| Test type | `platforms` param | Behaviour on mobile | Behaviour on web |
|-----------|-------------------|---------------------|------------------|
| Both platforms | _(omit)_ | runs | runs |
| Web-only | `[TestPlatform.web]` | skipped | runs |
| Mobile-only | `[TestPlatform.mobile]` | runs | skipped |

## Consequences

- Migration touches ~200 files but changes are mechanical — suitable for scripted bulk update.
- Atomic PR (base + scenarios + test files) will be large; review it as a structural change, not a logic change.
- After migration, shared base robots keep web implementations minimal — only the genuinely different method is overridden.
