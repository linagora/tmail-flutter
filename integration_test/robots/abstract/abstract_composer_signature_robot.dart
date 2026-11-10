/// Web only: identity signature checks inside the Summernote iframe.
abstract class AbstractComposerSignatureRobot {
  /// Waits until a visible signature containing [marker] is in the editor.
  Future<void> waitForSignatureMarker(String marker);

  /// A reopened draft shows the identity signature once, not hidden.
  Future<void> expectSingleVisibleSignature(String marker);

  /// Appends [appendedText] inside the signature containing [marker].
  Future<void> editSignature(String marker, String appendedText);

  /// Selects the composer identity named [identityName].
  Future<void> switchIdentity(String identityName);

  /// Waits for the single signature with [marker] and no [absentText].
  Future<void> expectOnlySignature(
    String marker, {
    required List<String> absentText,
  });
}
