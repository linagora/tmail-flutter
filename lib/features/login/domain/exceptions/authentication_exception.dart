
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';

abstract class AuthenticationException extends RemoteException {
  static const wrongCredential = 'Credential is wrong';
  static const badGateway = 'Bad gateway';
  static const invalidBaseUrl = 'Invalid base URL';

  AuthenticationException(String message) : super(message: message);
}

class BadCredentials extends AuthenticationException {
  BadCredentials() : super(AuthenticationException.wrongCredential);
}

class BadGateway extends AuthenticationException {
  BadGateway() : super(AuthenticationException.badGateway);
}

class NotFoundAuthenticatedAccountException implements Exception {}

class NotFoundStoredTokenException implements Exception {}

class InvalidBaseUrl extends AuthenticationException {
  InvalidBaseUrl() : super(AuthenticationException.invalidBaseUrl);
}

class AccessTokenInvalidException implements Exception {}

class DownloadAttachmentHasTokenExpiredException implements Exception {

  final String refreshToken;

  DownloadAttachmentHasTokenExpiredException(this.refreshToken);
}

class CanNotFoundBaseUrl implements Exception {}

class CanNotFoundUserName implements Exception {}

class CanNotFoundPassword implements Exception {}

class NotFoundAuthenticationInfoCache implements Exception {}

class CanNotFoundSaasServerUrl implements Exception {}

class SaasServerUriIsNull implements Exception {}

/// OIDC Configuration Exceptions
/// These exceptions provide detailed error information for OIDC-related issues

class OidcConfigurationException implements Exception {
  final String message;
  final String? technicalDetails;

  OidcConfigurationException(this.message, {this.technicalDetails});

  @override
  String toString() => 'OidcConfigurationException: $message${technicalDetails != null ? ' ($technicalDetails)' : ''}';
}

class MissingEndSessionEndpointException extends OidcConfigurationException {
  MissingEndSessionEndpointException()
      : super(
          'OIDC logout endpoint not configured',
          technicalDetails: 'end_session_endpoint missing from OIDC discovery',
        );
}

class MissingAuthorizationEndpointException extends OidcConfigurationException {
  MissingAuthorizationEndpointException()
      : super(
          'OIDC authorization endpoint not configured',
          technicalDetails: 'authorization_endpoint missing from OIDC discovery',
        );
}

class MissingTokenEndpointException extends OidcConfigurationException {
  MissingTokenEndpointException()
      : super(
          'OIDC token endpoint not configured',
          technicalDetails: 'token_endpoint missing from OIDC discovery',
        );
}

class OidcDiscoveryFailedException extends OidcConfigurationException {
  OidcDiscoveryFailedException(String details)
      : super(
          'Failed to retrieve OIDC configuration',
          technicalDetails: details,
        );
}

/// Exception thrown during OAuth web redirect flow when auto-redirecting
/// after storing the authorize destination URL. This is silently handled
/// as it indicates a normal redirect flow, not an error condition.
class AutoRedirectToAppAfterStoreAuthorizeDestinationUrlException
    implements Exception {}