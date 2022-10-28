import 'package:tmail_ui_user/main/exceptions/cache_exception.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class CacheExceptionThrower extends ExceptionThrower {

  @override
  void throwException(dynamic exception) {
    throw UnknownCacheError(message: exception.toString());
  }
}