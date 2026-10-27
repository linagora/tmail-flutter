/// Web only: the composer's "Embed code" HTML source view.
abstract class AbstractComposerCodeViewRobot {
  Future<void> openEmbedCode();

  /// Types HTML whose event handler leaves a trace on the page if it runs.
  Future<void> typeActiveContentPayload();

  Future<void> pressEscape();

  Future<void> expectActiveContentDidNotRun();
}
