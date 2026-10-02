/// Decides which links found in untrusted content (email bodies rendered in
/// a WebView) may be handed to the operating system.
///
/// Single allow-list for links in untrusted content: applied by the HTML
/// sanitizer (`SanitizeHtml`) and again when a link is tapped.
///
/// Custom schemes are refused: they could trigger other applications, or
/// this application itself through its own deep links, from a single click
/// in a received email.
class ExternalLinkPolicy {
  const ExternalLinkPolicy._();

  // A scheme added here must also be declared in AndroidManifest <queries> and iOS LSApplicationQueriesSchemes.
  static const Set<String> _allowedSchemes = {'http', 'https', 'tel', 'mailto', 'sms', 'webcal', 'geo'};

  static bool canLaunchFromContent(Uri uri) =>
      _allowedSchemes.contains(uri.scheme.toLowerCase());

  /// Whether an `<a href>` from untrusted content stays in the sanitized HTML.
  /// Relative and fragment links stay; protocol-relative links do not.
  static bool canKeepInContent(String href) {
    final uri = Uri.tryParse(href);
    if (uri == null) return false;
    if (!uri.hasScheme) return uri.host.isEmpty;
    return canLaunchFromContent(uri);
  }
}
