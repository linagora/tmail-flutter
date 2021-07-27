import 'package:equatable/equatable.dart';

abstract class AuthenticationException extends Equatable {
  static final wrongCredential = 'Credential is wrong';

  AuthenticationException(String message);
}

class BadCredentials extends AuthenticationException {
  BadCredentials() : super(AuthenticationException.wrongCredential);

  @override
  List<Object> get props => [];
}