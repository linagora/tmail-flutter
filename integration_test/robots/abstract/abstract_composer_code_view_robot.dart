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

  /// Minimizes the composer, then shows it again (rebuilds the editor).
  Future<void> minimizeAndRestoreComposer();

  /// Reads the editor HTML and writes it back, as Fullscreen does.
  Future<void> writeBackEditorHtml();

  /// Still in Embed code after Escape (or a write-back that must not leave).
  Future<void> expectStillInCodeView();

  /// Checks both that nothing ran and that the editor holds no active markup.
  Future<void> expectActiveContentDidNotRun();

  /// Checks the composer's cached body, read by send, drafts and print.
  Future<void> expectCachedBodyHasNoActiveContent();
}
