import 'package:core/domain/exceptions/app_base_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';

abstract class AuthenticationException extends RemoteException {
  static const wrongCredential = 'Credential is wrong';
  static const badGateway = 'Bad gateway';
  static const invalidBaseUrl = 'Invalid base URL';

  AuthenticationException(String message) : super(message: message);
}

class BadCredentials extends AuthenticationException {
  BadCredentials() : super(AuthenticationException.wrongCredential);

  @override
  String get exceptionName => 'BadCredentials';
}

class BadGateway extends AuthenticationException {
  BadGateway() : super(AuthenticationException.badGateway);

  @override
  String get exceptionName => 'BadGateway';
}

class InvalidBaseUrl extends AuthenticationException {
  InvalidBaseUrl() : super(AuthenticationException.invalidBaseUrl);

  @override
  String get exceptionName => 'InvalidBaseUrl';
}

class NotFoundAuthenticatedAccountException extends AppBaseException {
  NotFoundAuthenticatedAccountException([super.message]);

  @override
  String get exceptionName => 'NotFoundAuthenticatedAccountException';
}

class NotFoundStoredTokenException extends AppBaseException {
  NotFoundStoredTokenException([super.message]);

  @override
  String get exceptionName => 'NotFoundStoredTokenException';
}

class AccessTokenInvalidException extends AppBaseException {
  AccessTokenInvalidException([super.message]);

  @override
  String get exceptionName => 'AccessTokenInvalidException';
}

class DownloadAttachmentHasTokenExpiredException extends AppBaseException {
  final String refreshToken;

  DownloadAttachmentHasTokenExpiredException(this.refreshToken)
      : super('Token expired for refresh token');

  @override
  String get exceptionName => 'DownloadAttachmentHasTokenExpiredException';
}

class CanNotFoundBaseUrl extends AppBaseException {
  CanNotFoundBaseUrl([super.message]);

  @override
  String get exceptionName => 'CanNotFoundBaseUrl';
}

class CanNotFoundUserName extends AppBaseException {
  CanNotFoundUserName([super.message]);

  @override
  String get exceptionName => 'CanNotFoundUserName';
}

class CanNotFoundPassword extends AppBaseException {
  CanNotFoundPassword([super.message]);

  @override
  String get exceptionName => 'CanNotFoundPassword';
}

class NotFoundAuthenticationInfoCache extends AppBaseException {
  NotFoundAuthenticationInfoCache([super.message]);

  @override
  String get exceptionName => 'NotFoundAuthenticationInfoCache';
}

class CanNotFoundSaasServerUrl extends AppBaseException {
  CanNotFoundSaasServerUrl([super.message]);

  @override
  String get exceptionName => 'CanNotFoundSaasServerUrl';
}

class SaasServerUriIsNull extends AppBaseException {
  SaasServerUriIsNull([super.message]);

  @override
  String get exceptionName => 'SaasServerUriIsNull';
}

class AutoRedirectToAppAfterStoreAuthorizeDestinationUrlException extends AppBaseException {
  AutoRedirectToAppAfterStoreAuthorizeDestinationUrlException([super.message]);

  @override
  String get exceptionName => 'AutoRedirectToAppAfterStoreAuthorizeDestinationUrlException';
}
