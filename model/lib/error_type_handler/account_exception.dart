import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundPersonalAccountException extends AppBaseException {
  const NotFoundPersonalAccountException([super.message]);

  @override
  String get exceptionName => 'NotFoundPersonalAccountException';
}
