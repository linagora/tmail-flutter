import '../../base/base_test_scenario.dart';
import '../../robots/abstract/abstract_composer_editor_keyboard_robot.dart';

class NestBulletListWithKeyboardScenario extends BaseTestScenario {
  const NestBulletListWithKeyboardScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    await robots.commonRobot().waitForMailboxReady();

    final composerRobot = robots.composerRobot();
    final keyboardRobot = composerRobot.editorKeyboard!;

    await robots.threadRobot().openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    await composerRobot.addContent('one');
    await keyboardRobot.startBulletListViaKeyboardShortcut();
    await _stepTabOnFirstItem(keyboardRobot);
    await _stepNestSecondItem(keyboardRobot);
    await _stepOutdentEmptyNestedItem(keyboardRobot);

    await keyboardRobot.assertion.expectEditorListSkeleton(
      'ul[li[one ul[li[two]]] li[three]]',
    );
  }

  // The first item has no item above it to nest under: Tab must neither add a
  // bullet nor move focus out of the editor.
  Future<void> _stepTabOnFirstItem(
    AbstractComposerEditorKeyboardRobot keyboardRobot,
  ) async {
    await keyboardRobot.pressEditorKey('Tab');
    await keyboardRobot.pressEditorKey('Tab');
  }

  Future<void> _stepNestSecondItem(
    AbstractComposerEditorKeyboardRobot keyboardRobot,
  ) async {
    await keyboardRobot.pressEditorKey('Enter');
    await keyboardRobot.enterTextWithKeyboard('two');
    await keyboardRobot.pressEditorKey('Tab');
  }

  // Enter on the new empty nested item moves it back to the top level.
  Future<void> _stepOutdentEmptyNestedItem(
    AbstractComposerEditorKeyboardRobot keyboardRobot,
  ) async {
    await keyboardRobot.pressEditorKey('Enter');
    await keyboardRobot.pressEditorKey('Enter');
    await keyboardRobot.enterTextWithKeyboard('three');
  }
}
