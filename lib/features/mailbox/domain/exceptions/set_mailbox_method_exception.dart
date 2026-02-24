import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundMailboxCreatedException extends AppBaseException {
  NotFoundMailboxCreatedException([super.message]);

  @override
  String get exceptionName => 'NotFoundMailboxCreatedException';
}

class NotFoundMailboxUpdatedRoleException extends AppBaseException {
  NotFoundMailboxUpdatedRoleException([super.message]);

  @override
  String get exceptionName => 'NotFoundMailboxUpdatedRoleException';
}
