import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';

class RemoteExceptionThrower extends ExceptionThrower {

  @override
  void throwException(dynamic exception) {
    if (exception is DioError) {
      switch (exception.type) {
        case DioErrorType.connectTimeout:
          throw const ConnectError();
        default:
          if (exception.response?.statusCode == 502) {
            throw BadGateway();
          } else {
            throw UnknownError(
              code: exception.response?.statusCode,
              message: exception.response?.statusMessage);
          }
      }
    } else if (exception is ErrorMethodResponseException) {
      final errorResponse = exception.errorResponse as ErrorMethodResponse;
      if (errorResponse is CannotCalculateChangesMethodResponse) {
        throw CannotCalculateChangesMethodResponseException();
      } else {
        throw MethodLevelErrors(
          errorResponse.type,
          message: errorResponse.description);
      }
    } else {
      throw UnknownError(message: exception.toString());
    }
  }
}