/// Decides which links found in untrusted content (email bodies rendered in
/// a WebView) may be handed to the operating system.
///
/// Custom schemes are refused: they could trigger other applications, or
/// this application itself through its own deep links, from a single click
/// in a received email.
class ExternalLinkPolicy {
  const ExternalLinkPolicy._();

  static const Set<String> _allowedSchemes = {'http', 'https', 'tel'};

  static bool canLaunchFromContent(Uri uri) =>
      _allowedSchemes.contains(uri.scheme.toLowerCase());
}
