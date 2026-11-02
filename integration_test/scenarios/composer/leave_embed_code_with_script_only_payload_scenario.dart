import '../../base/base_test_scenario.dart';

class LeaveEmbedCodeWithScriptOnlyPayloadScenario extends BaseTestScenario {
  const LeaveEmbedCodeWithScriptOnlyPayloadScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    await robots.commonRobot().waitForMailboxReady();

    final composerRobot = robots.composerRobot();
    final codeViewRobot = composerRobot.codeView!;

    await robots.threadRobot().openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    await codeViewRobot.openEmbedCode();
    // The sanitizer turns this into an empty string, which Summernote ignores
    // in code view, so the raw textarea would be applied on the way out.
    await codeViewRobot.typeScriptOnlyPayload();
    await codeViewRobot.leaveEmbedCode();

    await codeViewRobot.expectActiveContentDidNotRun();
    await composerRobot.expectComposerViewVisible();
  }
}
