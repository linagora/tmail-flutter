import 'package:core/domain/exceptions/app_base_exception.dart';
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';

class CacheExceptionThrower extends ExceptionThrower {

  @override
  throwException(dynamic error, dynamic stackTrace) {
    switch (error) {
      case AppBaseException():
        logWarning(
          'CacheExceptionThrower::throwException(): expected ${error.runtimeType}: $error',
        );
      default:
        logError(
          'CacheExceptionThrower::throwException(): unrecognised error',
          exception: error,
          stackTrace: stackTrace,
        );
    }
    throw error;
  }
}