import '../../base/base_test_scenario.dart';

class RestoreMinimizedComposerAfterEmbedCodeScenario extends BaseTestScenario {
  const RestoreMinimizedComposerAfterEmbedCodeScenario(super.$, super.robots);

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
    // The rebuilt editor loads the composer's cached body, which code view
    // fills with the raw textarea HTML.
    await codeViewRobot.minimizeAndRestoreComposer();

    await codeViewRobot.expectActiveContentDidNotRun();
  }
}
