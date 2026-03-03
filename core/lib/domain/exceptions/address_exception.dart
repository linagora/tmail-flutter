import 'package:core/domain/exceptions/app_base_exception.dart';

class AddressException extends AppBaseException {
  const AddressException(super.message);

  @override
  String get exceptionName => 'AddressException';
}
