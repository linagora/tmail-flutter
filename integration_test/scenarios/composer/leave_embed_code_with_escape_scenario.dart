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

    // Escape must not leave code view. A vacuous DOM check on the editable
    // would pass if Escape were a no-op while still showing pre-code-view HTML.
    await codeViewRobot.expectStillInCodeView();
    await codeViewRobot.expectActiveContentDidNotRun();
    await composerRobot.expectComposerViewVisible();
  }
}
