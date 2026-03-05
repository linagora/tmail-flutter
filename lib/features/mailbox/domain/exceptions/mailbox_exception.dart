import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundInboxMailboxException extends AppBaseException {
  NotFoundInboxMailboxException([super.message]);

  @override
  String get exceptionName => 'NotFoundInboxMailboxException';
}

class NotFoundMailboxException extends AppBaseException {
  NotFoundMailboxException([super.message]);

  @override
  String get exceptionName => 'NotFoundMailboxException';
}

class NotFoundClearMailboxResponseException extends AppBaseException {
  NotFoundClearMailboxResponseException([super.message]);

  @override
  String get exceptionName => 'NotFoundClearMailboxResponseException';
}

class CannotMoveAllEmailException extends AppBaseException {
  CannotMoveAllEmailException([super.message]);

  @override
  String get exceptionName => 'CannotMoveAllEmailException';
}
