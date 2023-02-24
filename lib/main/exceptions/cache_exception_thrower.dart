import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class CacheExceptionThrower extends ExceptionThrower {

  @override
  throwException(dynamic error) {
    throw error;
  }
}