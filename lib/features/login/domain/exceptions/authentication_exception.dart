import 'package:equatable/equatable.dart';

abstract class AuthenticationException extends Equatable {
  static const wrongCredential = 'Credential is wrong';
  static const invalidBaseUrl = 'Invalid base URL';

  const AuthenticationException(String message);
}

class BadCredentials extends AuthenticationException {
  const BadCredentials() : super(AuthenticationException.wrongCredential);

  @override
  List<Object> get props => [];
}

class NotFoundAuthenticatedAccountException implements Exception {
  NotFoundAuthenticatedAccountException();
}

class NotFoundStoredTokenException implements Exception {
  NotFoundStoredTokenException();
}

class InvalidBaseUrl extends AuthenticationException {
  const InvalidBaseUrl() : super(AuthenticationException.invalidBaseUrl);

  @override
  List<Object?> get props => [];
}

class NotFoundAccessTokenException implements Exception {
  NotFoundAccessTokenException();
}

class AccessTokenInvalidException implements Exception {
  AccessTokenInvalidException();
}

class DownloadAttachmentHasTokenExpiredException implements Exception {

  final String refreshToken;

  DownloadAttachmentHasTokenExpiredException(this.refreshToken);
}