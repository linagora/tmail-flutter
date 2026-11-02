import '../../base/base_test_scenario.dart';

class CloseComposerWithEscapeInSubjectScenario extends BaseTestScenario {
  const CloseComposerWithEscapeInSubjectScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    await robots.commonRobot().waitForMailboxReady();

    final composerRobot = robots.composerRobot();
    final keyboardRobot = robots.hardwareKeyboardRobot()!;

    await robots.threadRobot().openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    // Leaves focus in the Flutter subject field, outside the editor iframe.
    await composerRobot.addSubject('escape from subject');
    await keyboardRobot.pressKey('Escape');

    await composerRobot.expectComposerClosedDiscardingChanges();
  }
}
