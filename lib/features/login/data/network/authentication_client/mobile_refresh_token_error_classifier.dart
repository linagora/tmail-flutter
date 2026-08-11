import 'package:tmail_ui_user/features/login/data/network/authentication_client/refresh_token_error_classifier.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/oauth_authorization_error.dart';

/// Classifies the refresh failures thrown by flutter_appauth (native).
///
/// The native refresh never reaches Dio, so a token-endpoint rejection arrives
/// as an [OAuthAuthorizationError] carrying the RFC 6749 code that the
/// authorization server returned in the 400 body.
///
/// A failure with no OAuth2 code (connectivity, DNS, no browser) keeps its
/// original PlatformException type and never reaches this classifier, so a
/// flaky connection cannot be read as a rejection.
class MobileRefreshTokenErrorClassifier extends RefreshTokenErrorClassifier {
  @override
  String get rejectedAuthErrorType => 'token_endpoint_oauth_rejected';

  @override
  String get unclassifiedAuthErrorType => 'token_endpoint_oauth_unknown_error';

  @override
  bool isPlatformRejection(Object error) {
    if (error is! OAuthAuthorizationError) return false;
    if (RefreshTokenErrorClassifier.badGrantCodes.contains(error.error)) {
      return true;
    }
    // Defensive: an authorization server may answer with the wrapper code
    // `token_failed` and put the real RFC 6749 code in the description,
    // the way flutter_appauth_web does.
    if (error.error == 'token_failed') {
      final desc = error.message?.trim();
      return desc != null &&
          RefreshTokenErrorClassifier.badGrantCodes.contains(desc);
    }
    return false;
  }

  @override
  Map<String, dynamic> buildPlatformSentryExtras(Object error) {
    if (error is! OAuthAuthorizationError) return const {};
    return {
      'oauth_error_code': error.error,
      'oauth_error_description': error.message ?? 'unknown',
    };
  }
}
