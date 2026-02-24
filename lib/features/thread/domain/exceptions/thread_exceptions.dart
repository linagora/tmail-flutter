import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundEmailsDeletedException extends AppBaseException {
  NotFoundEmailsDeletedException([super.message]);

  @override
  String get exceptionName => 'NotFoundEmailsDeletedException';
}

class InteractorIsNullException extends AppBaseException {
  InteractorIsNullException([super.message]);

  @override
  String get exceptionName => 'InteractorIsNullException';
}
