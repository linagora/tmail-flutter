import 'package:core/domain/exceptions/app_base_exception.dart';

class NullQuotaException extends AppBaseException {
  NullQuotaException([super.message]);

  @override
  String get exceptionName => 'NullQuotaException';
}
