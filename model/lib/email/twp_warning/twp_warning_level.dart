
/// Severity level carried by an `X-TWP-Message` header.
///
/// Maps to the banner color displayed in the read view:
/// info -> blue, warn -> yellow, error -> red.
enum TwpWarningLevel {
  info,
  warn,
  error;

  /// Parses the `level:` token value case-insensitively.
  ///
  /// Unknown or missing levels default to [TwpWarningLevel.info].
  static TwpWarningLevel fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'warn':
        return TwpWarningLevel.warn;
      case 'error':
        return TwpWarningLevel.error;
      default:
        return TwpWarningLevel.info;
    }
  }
}
