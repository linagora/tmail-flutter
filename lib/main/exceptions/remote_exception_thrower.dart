import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';

class RemoteExceptionThrower extends ExceptionThrower {

  @override
  void throwException(dynamic error) {
    if (error is DioError) {
      switch (error.type) {
        case DioErrorType.connectTimeout:
          throw const ConnectError();
        default:
          if (error.response?.statusCode == 502) {
            throw BadGateway();
          } else {
            throw UnknownError(
              code: error.response?.statusCode,
              message: error.response?.statusMessage);
          }
      }
    } else if (error is ErrorMethodResponseException) {
      final errorResponse = error.errorResponse as ErrorMethodResponse;
      if (errorResponse is CannotCalculateChangesMethodResponse) {
        throw CannotCalculateChangesMethodResponseException();
      } else {
        throw MethodLevelErrors(
          errorResponse.type,
          message: errorResponse.description);
      }
    } else {
      throw UnknownError(message: error.toString());
    }
  }
}