class PaywallUtils {
  const PaywallUtils._();

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
