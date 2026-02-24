import 'package:core/domain/exceptions/app_base_exception.dart';

class InvalidMailFormatException extends AppBaseException {
  final String mail;

  InvalidMailFormatException(this.mail) : super('Email: $mail');

  @override
  String get exceptionName => 'InvalidMailFormatException';
}
