/// Web only: the composer's "Embed code" HTML source view.
abstract class AbstractComposerCodeViewRobot {
  Future<void> openEmbedCode();

  /// Types HTML whose event handler leaves a trace on the page if it runs.
  Future<void> typeActiveContentPayload();

  /// Types a lone `<script>` that the sanitizer removes entirely.
  Future<void> typeScriptOnlyPayload();

  /// Leaves code view with the Embed code button.
  Future<void> leaveEmbedCode();

  Future<void> pressEscape();

  /// Checks both that nothing ran and that the editor holds no active markup.
  Future<void> expectActiveContentDidNotRun();
}
