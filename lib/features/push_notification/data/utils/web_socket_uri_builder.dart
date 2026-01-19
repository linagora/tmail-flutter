/// Utility class for building and manipulating WebSocket URIs.
///
/// Provides helper methods for adding query parameters and redacting
/// sensitive information from URIs for safe logging.
class WebSocketUriBuilder {
  /// Set of query parameter keys that contain sensitive data.
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
