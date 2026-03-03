import 'package:core/domain/exceptions/app_base_exception.dart';

class DataResponseIsNullException extends AppBaseException {
  const DataResponseIsNullException([super.message]);

  @override
  String get exceptionName => 'DataResponseIsNullException';
}
