import 'package:core/core.dart';

/// Utility class for generating web links in flat subdomain format.
class WebLinkGenerator {
  const WebLinkGenerator();

  /// Ensures that a path starts with `/`.
  String ensureFirstSlash(String? path) {
    if (path == null || path.isEmpty) return '/';
    return path.startsWith('/') ? path : '/$path';
  }

  /// Validates if a given FQDN looks valid (has at least 2 parts and non-empty).
  bool isValidFqdn(String fqdn) {
    if (fqdn.trim().isEmpty || !fqdn.contains('.')) return false;
    final parts = fqdn.split('.').where((p) => p.trim().isNotEmpty).toList();
    return parts.length >= 2;
  }

  /// Generates a web link based on a workplace FQDN and app slug.
  ///
  /// Throws [ArgumentError] when input is invalid.
  String generateWebLink({
    required String workplaceFqdn,
    required String slug,
    String? pathname,
    String? hash,
    List<List<String>>? searchParams,
  }) {
    if (!isValidFqdn(workplaceFqdn)) {
      throw ArgumentError('Invalid workplace FQDN: $workplaceFqdn');
    }

    final hostParts = workplaceFqdn
        .split('.')
        .where((p) => p.trim().isNotEmpty)
        .toList();

    hostParts[0] = '${hostParts[0]}-$slug';
    final newHost = hostParts.join('.');

    final safePath = ensureFirstSlash(pathname);
    final safeHash = (hash == null || hash.isEmpty) ? null : ensureFirstSlash(hash);

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
  String safeGenerateWebLink({
    required String workplaceFqdn,
    required String slug,
    String? pathname,
    String? hash,
    List<List<String>>? searchParams,
  }) {
    try {
      if (slug.trim().isEmpty) return '';

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
