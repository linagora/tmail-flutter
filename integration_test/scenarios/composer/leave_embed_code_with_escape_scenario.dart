import '../../base/base_test_scenario.dart';

class LeaveEmbedCodeWithEscapeScenario extends BaseTestScenario {
  const LeaveEmbedCodeWithEscapeScenario(super.$, super.robots);

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
    // Summernote leaves code view on Escape by itself; that exit must not
    // skip the sanitizer the Embed code button goes through.
    await codeViewRobot.pressEscape();

    await codeViewRobot.expectActiveContentDidNotRun();
    // Escape in the code view never closes the composer.
    await composerRobot.expectComposerViewVisible();
  }
}
