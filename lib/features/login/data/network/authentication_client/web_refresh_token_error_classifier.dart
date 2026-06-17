import 'package:dio/dio.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart'
    show AccessTokenInvalidException;

/// Classifies web token-refresh errors according to RFC 6749 §5.2.
/// https://datatracker.ietf.org/doc/html/rfc6749#section-5.2
///
/// Single responsibility: answer two questions —
///   1. Is this error a definitive server rejection (400/401 equivalent)?
///   2. What structured extras should go to Sentry for tracing?
///
/// Intentionally has NO dependency on Dio handler operations or interceptor
/// state; callers act on the result (logout, keep session, log).
class WebRefreshTokenErrorClassifier {
  /// Standard RFC 6749 §5.2 token-endpoint error codes that map to a
  /// definitive 400/401 rejection — logout is safe.
  /// Non-standard codes (e.g. "token_failed") are absent intentionally;
  /// they are logged to Sentry until their HTTP status is confirmed.
  static const _badGrantCodes = {
    'invalid_grant',          // refresh token expired or revoked (400)
    'invalid_client',         // client authentication failed (400 or 401)
    'invalid_request',        // request was malformed (400)
    'invalid_scope',          // requested scope exceeds original grant (400)
    'unauthorized_client',    // client not authorized for this grant type (400)
    'unsupported_grant_type', // grant type not supported by the server (400)
  };

  /// Returns `true` when [error] represents a confirmed server-side rejection
  /// that maps to HTTP 400 or 401, making logout the correct response.
  bool isServerRejection(Object error) {
    if (error is AccessTokenInvalidException) return true;
    if (error is ArgumentError) return _isArgumentErrorRejection(error);
    if (error is DioException) return _isDioRejection(error);
    return false;
  }

  bool _isArgumentErrorRejection(ArgumentError error) {
    final code = _parseOAuthCode(error);
    if (code != null && _badGrantCodes.contains(code)) return true;
    // flutter_appauth_web always wraps non-200 token responses as
    // [error: token_failed, description: <actual-rfc-6749-code>].
    // When the code is 'token_failed', the real rejection signal lives in
    // the description field.
    if (code == 'token_failed') {
      final desc = _parseOAuthDesc(error);
      return desc != null && _badGrantCodes.contains(desc);
    }
    return false;
  }

  bool _isDioRejection(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 400 || statusCode == 401;
  }

  /// Builds structured Sentry extras for [error].
  ///
  /// For [ArgumentError], includes [oauth_error_code] and
  /// [oauth_error_description] parsed from the flutter_appauth_web message so
  /// that non-standard codes (e.g. "token_failed") are fully visible in Sentry.
  Map<String, dynamic> buildSentryExtras(Object error) {
    final rejected = isServerRejection(error);
    final extras = <String, dynamic>{
      'auth_error_type': rejected
          ? 'web_server_rejected_refresh'
          : 'web_token_unknown_error',
    };
    if (error is ArgumentError) {
      extras['oauth_error_code'] = _parseOAuthCode(error) ?? 'unknown';
      extras['oauth_error_description'] = _parseOAuthDesc(error) ?? 'unknown';
    }
    return extras;
  }

  // Parses the OAuth2 `error` field from flutter_appauth_web's ArgumentError
  // message format: "Failed to get token: [error: X, description: Y]"
  String? _parseOAuthCode(ArgumentError error) => RegExp(r'\[error: ([^,\]]+)')
      .firstMatch(error.message?.toString() ?? '')
      ?.group(1)
      ?.trim();

  String? _parseOAuthDesc(ArgumentError error) =>
      RegExp(r'description: ([^\]]+)\]')
          .firstMatch(error.message?.toString() ?? '')
          ?.group(1)
          ?.trim();
}
