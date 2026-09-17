import 'package:core/utils/web_link_generator.dart';

class PaywallUtils {
  const PaywallUtils._();

  static Uri? _parseWorkplaceUri(String workplaceFqdn) {
    final uri = Uri.tryParse(workplaceFqdn);
    if (uri == null) return null;
    if (uri.hasScheme) return uri;
    return Uri.tryParse('https://$workplaceFqdn');
  }

  static bool _isSecureAbsoluteUri(Uri uri) {
    if (uri.scheme.toLowerCase() != 'https') return false;
    if (uri.userInfo.isNotEmpty) return false;
    return uri.host.isNotEmpty;
  }

  static String buildWorkplacePaywallUrl(String? workplaceFqdn) {
    final normalizedFqdn = workplaceFqdn?.trim();
    if (normalizedFqdn == null) return '';
    if (normalizedFqdn.isEmpty) return '';

    final uri = _parseWorkplaceUri(normalizedFqdn);
    if (uri == null) return '';
    if (!_isSecureAbsoluteUri(uri)) return '';
    if (!WebLinkGenerator.isValidFqdn(uri.host)) return '';

    return Uri(
      scheme: 'https',
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: '/settings/premium',
    ).toString();
  }

  static bool isValidPaywallUrl(String? url) {
    final normalizedUrl = url?.trim();
    if (normalizedUrl == null) return false;
    if (normalizedUrl.isEmpty) return false;

    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null) return false;
    if (!_isSecureAbsoluteUri(uri)) return false;
    return WebLinkGenerator.isValidFqdn(uri.host);
  }

  /// Builds a paywall URL from a template.
  ///
  /// - Supports both raw placeholders (`{localPart}`/`{localpart}`,
  ///   `{domainName}`/`{domainname}`) and their URL-encoded forms
  ///   (`%7BlocalPart%7D`, `%7BdomainName%7D`, ...).
  /// - If [localPart] or [domainName] is not provided, the placeholder
  ///   is removed.
  static String buildPaywallUrlFromTemplate({
    required String template,
    String? localPart,
    String? domainName,
  }) {
    var result = template;
    for (final name in const ['localPart', 'localpart']) {
      result = _replacePlaceholder(result, name, localPart);
    }
    for (final name in const ['domainName', 'domainname']) {
      result = _replacePlaceholder(result, name, domainName);
    }
    return result;
  }

  /// Replaces both the raw (`{name}`) and URL-encoded (`%7Bname%7D`) forms of
  /// a placeholder with [value], or removes it when [value] is null.
  static String _replacePlaceholder(String template, String name, String? value) {
    final resolved = value ?? '';
    return template
        .replaceAll('{$name}', resolved)
        .replaceAll(Uri.encodeComponent('{$name}'), resolved);
  }
}
