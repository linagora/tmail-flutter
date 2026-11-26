abstract class AbstractComposerEditorLinkAssertionRobot {
  /// Expects the editor link whose text is [text] to have [href]; a null
  /// [href] means the link must have no `href` attribute at all.
  Future<void> expectLinkHref(String text, String? href);
}
