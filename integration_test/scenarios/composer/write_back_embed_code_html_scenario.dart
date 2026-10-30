import '../../base/base_test_scenario.dart';

class WriteBackEmbedCodeHtmlScenario extends BaseTestScenario {
  const WriteBackEmbedCodeHtmlScenario(super.$, super.robots);

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
    // Fullscreen reads the code view HTML and writes it back through setText,
    // whose change event reaches the cached body.
    await codeViewRobot.writeBackEditorHtml();

    // Write-back stays in code view. setText only syncs the textarea there, so
    // an editable DOM check would not prove Fullscreen safety.
    await codeViewRobot.expectStillInCodeView();
    await codeViewRobot.expectCachedBodyHasNoActiveContent();
  }
}
