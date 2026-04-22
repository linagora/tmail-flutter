import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart' show BadGateway;
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/server_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/unknown_remote_exception.dart';

class DioResponseErrorHandler {
  void handle(Response response) {
    final statusCode = response.statusCode;
    switch (statusCode) {
      case HttpStatus.unauthorized:
        // 401 is handled by auth retry flow — no log needed
        throw const BadCredentialsException();
      case HttpStatus.internalServerError:
        logWarning('RemoteExceptionThrower: HTTP 500');
        throw const InternalServerError();
      case HttpStatus.badGateway:
        logWarning('RemoteExceptionThrower: HTTP 502');
        throw BadGateway();
      default:
        final exception = UnknownRemoteException(
          code: statusCode,
          message: response.statusMessage,
        );
        _logUnhandledStatusCode(statusCode, exception);
        throw exception;
    }
  }

  void _logUnhandledStatusCode(int? statusCode, UnknownRemoteException exception) {
    final is4xx = statusCode != null && statusCode >= 400 && statusCode < 500;
    final is5xx = statusCode != null && statusCode >= 500;
    if (is4xx) {
      logWarning('RemoteExceptionThrower: HTTP 4xx ($statusCode)');
    } else if (is5xx) {
      logWarning('RemoteExceptionThrower: HTTP 5xx ($statusCode)');
    } else {
      logError(
        'RemoteExceptionThrower: unknown HTTP status $statusCode',
        exception: exception,
      );
    }
  }
}
