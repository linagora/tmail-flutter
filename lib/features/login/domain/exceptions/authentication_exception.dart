
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

class NotFoundAccessTokenException implements Exception {}

class AccessTokenInvalidException implements Exception {}

class DownloadAttachmentHasTokenExpiredException implements Exception {

  final String refreshToken;

  DownloadAttachmentHasTokenExpiredException(this.refreshToken);
}

class CanNotFoundBaseUrl implements Exception {}

class CanNotFoundUserName implements Exception {}

class CanNotFoundPassword implements Exception {}

class CanNotAuthenticationInfoOnWeb implements Exception {}

class NotFoundAuthenticationInfoCache implements Exception {}

class CanNotFoundSaasServerUrl implements Exception {}

class SaasServerUriIsNull implements Exception {}