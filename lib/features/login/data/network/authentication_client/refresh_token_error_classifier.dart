import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart'
    show AccessTokenInvalidException;

/// Classifies token-refresh errors according to RFC 6749 §5.2.
/// https://datatracker.ietf.org/doc/html/rfc6749#section-5.2
///
/// Single responsibility: answer two questions —
///   1. Is this error a definitive server rejection (400/401 equivalent)?
///   2. What structured extras should go to Sentry for tracing?
///
/// Web and mobile refresh through different plugins, so the same rejection
/// surfaces as a different Dart type on each platform. Everything those two
/// have in common lives here; the platform-specific error shape is decided by
/// the subclass, which keeps one platform's error types from ever influencing
/// the other's verdict.
abstract class RefreshTokenErrorClassifier {
  /// Standard RFC 6749 §5.2 token-endpoint error codes that map to a
  /// definitive 400/401 rejection — logout is safe.
  /// Non-standard codes (e.g. "token_failed") are absent intentionally;
  /// they are logged to Sentry until their HTTP status is confirmed.
  static const badGrantCodes = {
    'invalid_grant',          // refresh token expired or revoked (400)
    'invalid_client',         // client authentication failed (400 or 401)
    'invalid_request',        // request was malformed (400)
    'invalid_scope',          // requested scope exceeds original grant (400)
    'unauthorized_client',    // client not authorized for this grant type (400)
    'unsupported_grant_type', // grant type not supported by the server (400)
  };

  /// Value of the `auth_error_type` Sentry field when the refresh was rejected.
  @protected
  String get rejectedAuthErrorType;

  /// Value of the `auth_error_type` Sentry field when the failure could not be
  /// classified — the session is kept and the event is a trace, not a verdict.
  @protected
  String get unclassifiedAuthErrorType;

  /// Returns `true` when [error] represents a confirmed server-side rejection
  /// that maps to HTTP 400 or 401, making logout the correct response.
  bool isServerRejection(Object error) {
    if (error is AccessTokenInvalidException) return true;
    if (error is DioException) return _isDioRejection(error);
    return isPlatformRejection(error);
  }

  /// Classifies the error type the platform's own refresh plugin throws.
  @protected
  bool isPlatformRejection(Object error);

  /// Sentry extras describing the platform-specific error shape, so the
  /// underlying OAuth2 code stays visible even for non-standard values.
  @protected
  Map<String, dynamic> buildPlatformSentryExtras(Object error) => const {};

  bool _isDioRejection(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode == 400 || statusCode == 401;
  }

  /// Builds structured Sentry extras for [error].
  Map<String, dynamic> buildSentryExtras(Object error) => {
        'auth_error_type': isServerRejection(error)
            ? rejectedAuthErrorType
            : unclassifiedAuthErrorType,
        ...buildPlatformSentryExtras(error),
      };
}
