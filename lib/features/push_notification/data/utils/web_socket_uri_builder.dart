/// Utility class for building and manipulating WebSocket URIs.
///
/// Provides helper methods for:
/// - Adding query parameters to URIs
/// - Redacting sensitive information from URIs for safe logging
///
/// ## Security
///
/// WebSocket authentication passes credentials via query parameters, which
/// may appear in logs. This class provides [redactSensitiveParams] to replace
/// sensitive values with `[REDACTED]` for safe logging.
///
/// ## Usage
///
/// ```dart
/// // Add authentication token
/// final uri = WebSocketUriBuilder.addQueryParam(baseUri, 'access_token', token);
///
/// // Safe logging
/// log('Connecting to ${WebSocketUriBuilder.redactSensitiveParams(uri)}');
/// // Output: Connecting to wss://server/ws?access_token=[REDACTED]
/// ```
class WebSocketUriBuilder {
  /// Set of query parameter keys that contain sensitive data.
  ///
  /// These parameters are redacted when logging URIs to prevent
  /// credential leakage.
  static const _sensitiveKeys = {'access_token', 'authorization', 'ticket'};

  /// Adds a query parameter to the URI.
  ///
  /// Preserves existing query parameters and adds the new key-value pair.
  static Uri addQueryParam(Uri uri, String key, String value) {
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      key: value,
    });
  }

  /// Adds multiple query parameters to the URI.
  ///
  /// Preserves existing query parameters and adds the new key-value pairs.
  static Uri addQueryParams(Uri uri, Map<String, String> params) {
    return uri.replace(queryParameters: {
      ...uri.queryParameters,
      ...params,
    });
  }

  /// Redacts sensitive query parameters from a URI for safe logging.
  ///
  /// Replaces values of sensitive parameters (access_token, authorization, ticket)
  /// with '[REDACTED]' to prevent credential leakage in logs.
  ///
  /// Example:
  /// ```dart
  /// final uri = Uri.parse('wss://server/ws?access_token=secret123');
  /// print(WebSocketUriBuilder.redactSensitiveParams(uri));
  /// // Output: wss://server/ws?access_token=[REDACTED]
  /// ```
  static String redactSensitiveParams(Uri uri) {
    if (!uri.queryParameters.keys.any(_sensitiveKeys.contains)) {
      return uri.toString();
    }

    final redacted = uri.queryParameters.map((key, value) =>
      MapEntry(key, _sensitiveKeys.contains(key) ? '[REDACTED]' : value));

    return uri.replace(queryParameters: redacted).toString();
  }

  /// Checks if a URI contains sensitive query parameters.
  static bool containsSensitiveParams(Uri uri) {
    return uri.queryParameters.keys.any(_sensitiveKeys.contains);
  }
}
