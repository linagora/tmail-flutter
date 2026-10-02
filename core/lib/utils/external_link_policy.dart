/// Decides which links found in untrusted content (email bodies rendered in
/// a WebView) may be handed to the operating system.
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
}
