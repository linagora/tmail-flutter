import '../../base/base_test_scenario.dart';

class CloseComposerWithEscapeInEditorScenario extends BaseTestScenario {
  const CloseComposerWithEscapeInEditorScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    await robots.commonRobot().waitForMailboxReady();

    final composerRobot = robots.composerRobot();
    final keyboardRobot = robots.hardwareKeyboardRobot()!;

    await robots.threadRobot().openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    // Leaves the caret in the editor body, inside the editor iframe.
    await composerRobot.addContent('hello');
    await keyboardRobot.pressKey('Escape');

    await composerRobot.expectComposerClosedDiscardingChanges();
  }
}
