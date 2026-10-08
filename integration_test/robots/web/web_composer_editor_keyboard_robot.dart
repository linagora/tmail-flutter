import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:patrol/patrol.dart';

import '../../base/core_robot.dart';
import '../abstract/abstract_composer_editor_assertion_robot.dart';
import '../abstract/abstract_composer_editor_keyboard_robot.dart';
import 'web_composer_editor_assertion_robot.dart';

/// Key presses go to the focused element, so the editor must already hold
/// focus (e.g. after `addContent`).
class WebComposerEditorKeyboardRobot extends CoreRobot
    implements AbstractComposerEditorKeyboardRobot {
  WebComposerEditorKeyboardRobot(PatrolIntegrationTester $) : super($);

  @override
  late final AbstractComposerEditorAssertionRobot assertion =
      WebComposerEditorAssertionRobot($);

  @override
  Future<void> startBulletListViaKeyboardShortcut() async {
    final isMac = defaultTargetPlatform == TargetPlatform.macOS;
    await $.platformAutomator.web.pressKeyCombo(
      keys: [isMac ? 'Meta' : 'Control', 'Shift', '7'],
    );
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> pressEditorKey(String key) async {
    await $.platformAutomator.web.pressKey(key: key);
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> enterTextWithKeyboard(String text) async {
    for (final character in text.split('')) {
      await $.platformAutomator.web.pressKey(key: character);
    }
    await $.pumpAndTrySettle();
  }
}
