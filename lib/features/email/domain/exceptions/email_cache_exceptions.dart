import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundStoredOpenedEmailException extends AppBaseException {
  NotFoundStoredOpenedEmailException([super.message]);

  @override
  String get exceptionName => 'NotFoundStoredOpenedEmailException';
}

class NotFoundStoredNewEmailException extends AppBaseException {
  NotFoundStoredNewEmailException([super.message]);

  @override
  String get exceptionName => 'NotFoundStoredNewEmailException';
}

class NotFoundStoredEmailException extends AppBaseException {
  NotFoundStoredEmailException([super.message]);

  @override
  String get exceptionName => 'NotFoundStoredEmailException';
}

class OpenedEmailAlreadyStoredException extends AppBaseException {
  OpenedEmailAlreadyStoredException([super.message]);

  @override
  String get exceptionName => 'OpenedEmailAlreadyStoredException';
}
