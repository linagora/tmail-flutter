
import 'package:core/utils/app_logger.dart';

/// Utility class for generating web links in flat subdomain format.
class WebLinkGenerator {
  /// Ensures that a path starts with `/`.
  static String ensureFirstSlash(String? path) {
    if (path == null || path.isEmpty) return '/';
    return path.startsWith('/') ? path : '/$path';
  }

  /// Validates if a given FQDN looks valid (has at least 2 parts and non-empty).
  static bool isValidFqdn(String fqdn) {
    if (fqdn.trim().isEmpty || !fqdn.contains('.')) return false;
    final parts = fqdn.split('.').where((p) => p.trim().isNotEmpty).toList();
    return parts.length >= 2;
  }

  /// Generates a web link based on a workplace FQDN and app slug.
  ///
  /// Throws [ArgumentError] when input is invalid.
  static String generateWebLink({
    required String workplaceFqdn,
    String? slug,
    String? pathname,
    String? hash,
    List<List<String>>? searchParams,
  }) {
    if (!isValidFqdn(workplaceFqdn)) {
      throw ArgumentError('Invalid workplace FQDN: $workplaceFqdn');
    }

    // Start from the base host
    String newHost = workplaceFqdn;

    // Only modify the host when slug is non-null and not empty
    if (slug != null && slug.trim().isNotEmpty) {
      final hostParts =
          workplaceFqdn.split('.').where((p) => p.trim().isNotEmpty).toList();

      // Insert slug as a prefix to the first part (flat subdomain)
      hostParts[0] = '${hostParts[0]}-$slug';
      newHost = hostParts.join('.');
    }

    final safePath = ensureFirstSlash(pathname);
    final safeHash =
        (hash == null || hash.isEmpty) ? null : ensureFirstSlash(hash);

    final queryParams = <String, String>{};
    for (final param in searchParams ?? const []) {
      if (param.length == 2) queryParams[param[0]] = param[1];
    }

    final uri = Uri(
      scheme: 'https',
      host: newHost,
      path: safePath,
      queryParameters: queryParams.isEmpty ? null : queryParams,
      fragment: safeHash,
    );

    return uri.toString();
  }

  /// A safe version of [generateWebLink] that **never throws**.
  ///
  /// Returns `''` (empty string) when an error occurs.
  static String safeGenerateWebLink({
    required String workplaceFqdn,
    String? slug,
    String? pathname,
    String? hash,
    List<List<String>>? searchParams,
  }) {
    try {
      return generateWebLink(
        workplaceFqdn: workplaceFqdn,
        slug: slug,
        pathname: pathname,
        hash: hash,
        searchParams: searchParams,
      );
    } catch (e) {
      logError('[WebLinkGenerator] Error: $e');
      return '';
    }
  }
}
