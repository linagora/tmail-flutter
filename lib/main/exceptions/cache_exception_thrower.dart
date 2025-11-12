import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class CacheExceptionThrower extends ExceptionThrower {

  @override
  Future<void> throwException(dynamic error, dynamic stackTrace) {
    logError('CacheExceptionThrower::throwException():error: $error | stackTrace: $stackTrace');
    throw error;
  }
}