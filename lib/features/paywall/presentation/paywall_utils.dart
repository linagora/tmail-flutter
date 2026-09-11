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

    return WebLinkGenerator.safeGenerateWebLink(
      workplaceFqdn: uri.host,
      pathname: '/settings/premium',
    );
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
  /// - Supports both raw placeholders (`{localPart}`, `{domainName}`)
  ///   and URL-encoded placeholders (`%7BlocalPart%7D`, `%7BdomainName%7D`).
  /// - If [localPart] or [domainName] is not provided, the placeholder
  ///   is removed.
  static String buildPaywallUrlFromTemplate({
    required String template,
    String? localPart,
    String? domainName,
  }) {
    final replacements = {
      '{localPart}': localPart ?? '',
      '{domainName}': domainName ?? '',
      Uri.encodeComponent('{localPart}'): localPart ?? '',
      Uri.encodeComponent('{domainName}'): domainName ?? '',
    };

    var result = template;
    replacements.forEach((placeholder, value) {
      result = result.replaceAll(placeholder, value);
    });

    return result;
  }
}
