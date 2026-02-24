import 'package:core/domain/exceptions/app_base_exception.dart';

class DataResponseIsNullException extends AppBaseException {
  DataResponseIsNullException([super.message]);

  @override
  String get exceptionName => 'DataResponseIsNullException';
}
