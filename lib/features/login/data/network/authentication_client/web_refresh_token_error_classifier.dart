import 'package:tmail_ui_user/features/login/data/network/authentication_client/refresh_token_error_classifier.dart';

/// Classifies the refresh failures thrown by flutter_appauth_web.
///
/// The web plugin reports every non-200 token response as an [ArgumentError]
/// whose message carries the OAuth2 fields:
/// `Failed to get token: [error: X, description: Y]`.
class WebRefreshTokenErrorClassifier extends RefreshTokenErrorClassifier {
  @override
  String get rejectedAuthErrorType => 'web_server_rejected_refresh';

  @override
  String get unclassifiedAuthErrorType => 'web_token_unknown_error';

  @override
  bool isPlatformRejection(Object error) {
    if (error is! ArgumentError) return false;
    final code = _parseOAuthCode(error);
    if (code != null &&
        RefreshTokenErrorClassifier.badGrantCodes.contains(code)) {
      return true;
    }
    // flutter_appauth_web always wraps non-200 token responses as
    // [error: token_failed, description: <actual-rfc-6749-code>].
    // When the code is 'token_failed', the real rejection signal lives in
    // the description field.
    if (code == 'token_failed') {
      final desc = _parseOAuthDesc(error);
      return desc != null &&
          RefreshTokenErrorClassifier.badGrantCodes.contains(desc);
    }
    return false;
  }

  /// Includes [oauth_error_code] and [oauth_error_description] parsed from the
  /// flutter_appauth_web message so that non-standard codes (e.g.
  /// "token_failed") are fully visible in Sentry.
  @override
  Map<String, dynamic> buildPlatformSentryExtras(Object error) {
    if (error is! ArgumentError) return const {};
    return {
      'oauth_error_code': _parseOAuthCode(error) ?? 'unknown',
      'oauth_error_description': _parseOAuthDesc(error) ?? 'unknown',
    };
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
