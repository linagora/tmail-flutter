import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundQuotasException extends AppBaseException {
  const NotFoundQuotasException([super.message]);

  @override
  String get exceptionName => 'NotFoundQuotasException';
}

class QuotasNotSupportedException extends AppBaseException {
  const QuotasNotSupportedException([super.message]);

  @override
  String get exceptionName => 'QuotasNotSupportedException';
}
