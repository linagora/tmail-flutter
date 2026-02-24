import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundQuotasException extends AppBaseException {
  NotFoundQuotasException([super.message]);

  @override
  String get exceptionName => 'NotFoundQuotasException';
}

class QuotasNotSupportedException extends AppBaseException {
  QuotasNotSupportedException([super.message]);

  @override
  String get exceptionName => 'QuotasNotSupportedException';
}
