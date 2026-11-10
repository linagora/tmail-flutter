/// Web only: identity signature checks inside the Summernote iframe.
abstract class AbstractComposerSignatureRobot {
  /// Waits until a visible signature containing [marker] is in the editor.
  Future<void> waitForSignatureMarker(String marker);

  /// A reopened draft shows the identity signature once, not hidden.
  Future<void> expectSingleVisibleSignature(String marker);
}
