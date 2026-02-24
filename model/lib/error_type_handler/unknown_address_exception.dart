import 'package:core/domain/exceptions/app_base_exception.dart';

class UnknownAddressException extends AppBaseException {
  const UnknownAddressException([super.message]);

  @override
  String get exceptionName => 'UnknownAddressException';
}
