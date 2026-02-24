import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundSessionException extends AppBaseException {
  NotFoundSessionException([super.message]);

  @override
  String get exceptionName => 'NotFoundSessionException';
}

class NotFoundAccountIdException extends AppBaseException {
  NotFoundAccountIdException([super.message]);

  @override
  String get exceptionName => 'NotFoundAccountIdException';
}

class NotFoundContextException extends AppBaseException {
  NotFoundContextException([super.message]);

  @override
  String get exceptionName => 'NotFoundContextException';
}

class ParametersIsNullException extends AppBaseException {
  ParametersIsNullException([super.message]);

  @override
  String get exceptionName => 'ParametersIsNullException';
}
