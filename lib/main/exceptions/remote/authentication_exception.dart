import 'package:tmail_ui_user/main/exceptions/remote/remote_exception.dart';

class AuthenticationException extends RemoteException {
  const AuthenticationException({super.message});

  @override
  String get exceptionName => 'AuthenticationException';
}

class BadCredentialsException extends AuthenticationException {
  const BadCredentialsException() : super(message: 'Bad credentials');

  @override
  String get exceptionName => 'BadCredentialsException';
}

class RefreshTokenFailedException extends AuthenticationException {
  RefreshTokenFailedException({
    int code = 400,
    String? message,
  }) : super(
          message: message ??
              'Refresh token failed with status $code. Session invalid or revoked.',
        );

  @override
  String get exceptionName => 'RefreshTokenFailedException';
}
