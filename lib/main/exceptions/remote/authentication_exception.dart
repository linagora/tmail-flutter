import 'package:tmail_ui_user/main/exceptions/remote/remote_exception.dart';

class AuthenticationException extends RemoteException {
  const AuthenticationException({super.code, super.message});

  @override
  String get exceptionName => 'AuthenticationException';
}

class BadCredentialsException extends AuthenticationException {
  const BadCredentialsException() : super(message: 'Bad credentials');

  @override
  String get exceptionName => 'BadCredentialsException';
}

class RefreshTokenFailedException extends AuthenticationException {
  /// The server rejection that killed the session, for the caller to log.
  final Object? cause;

  RefreshTokenFailedException({
    int code = 400,
    String? message,
    this.cause,
  }) : super(
          code: code,
          message: message ??
              'Refresh token failed with status $code. Session invalid or revoked.',
        );

  @override
  String get exceptionName => 'RefreshTokenFailedException';
}

class RefreshTokenDuplicatedException extends AuthenticationException {
  const RefreshTokenDuplicatedException()
      : super(message: 'Refresh returned the current token; retry cannot clear the 401.');

  @override
  String get exceptionName => 'RefreshTokenDuplicatedException';
}

/// The refresh answered for a session that no longer exists, so it says nothing
/// about whichever session is signed in now. Deliberately not a
/// [RefreshTokenFailedException]: that type forces a logout.
class StaleSessionRefreshException extends AuthenticationException {
  const StaleSessionRefreshException()
      : super(message: 'Refresh answered for a session that has since been replaced.');

  @override
  String get exceptionName => 'StaleSessionRefreshException';
}
