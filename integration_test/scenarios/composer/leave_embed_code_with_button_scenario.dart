import '../../base/base_test_scenario.dart';

class LeaveEmbedCodeWithButtonScenario extends BaseTestScenario {
  const LeaveEmbedCodeWithButtonScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    await robots.commonRobot().waitForMailboxReady();

    final composerRobot = robots.composerRobot();
    final codeViewRobot = composerRobot.codeView!;

    await robots.threadRobot().openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    await codeViewRobot.openEmbedCode();
    await codeViewRobot.typeActiveContentPayload();
    await codeViewRobot.leaveEmbedCode();

    await codeViewRobot.expectActiveContentDidNotRun();
    await composerRobot.expectComposerViewVisible();
  }
}
