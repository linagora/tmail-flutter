import 'package:equatable/equatable.dart';

abstract class AuthenticationException extends Equatable {
  static const wrongCredential = 'Credential is wrong';

  const AuthenticationException(String message);
}

class BadCredentials extends AuthenticationException {
  const BadCredentials() : super(AuthenticationException.wrongCredential);

  @override
  List<Object> get props => [];
}