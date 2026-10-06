/// Outcome of reading or writing the composer body through a driver.
sealed class ComposerBodyResult {
  const ComposerBodyResult();
}

class ComposerBodyFound extends ComposerBodyResult {
  const ComposerBodyFound(this.body);

  final Map<String, dynamic> body;
}

class ComposerNotFound extends ComposerBodyResult {
  const ComposerNotFound();
}

/// More than one composer is open, so the target editor is ambiguous.
class MultipleComposersFound extends ComposerBodyResult {
  const MultipleComposersFound();
}

/// Platform-specific access to the composer editor, which lives outside the
/// widget tree (an iframe on web, a WebView on mobile).
abstract interface class ComposerBodyDriver {
  /// Replaces the body with [text], keeping the signature. On success the
  /// body is `{'body': <plain text>}`.
  Future<ComposerBodyResult> setBody(String text);

  /// On success the body is `{'text': <plain text>, 'html': <markup>}`.
  Future<ComposerBodyResult> getBody();
}
