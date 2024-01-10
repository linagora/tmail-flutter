import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class RemoteExceptionThrower extends ExceptionThrower {

  @override
  throwException(dynamic error, dynamic stackTrace) {
    logError('RemoteExceptionThrower::throwException():error: $error | stackTrace: $stackTrace');
    final networkConnectionController = getBinding<NetworkConnectionController>();
    if (networkConnectionController?.isNetworkConnectionAvailable() == false) {
      logError('RemoteExceptionThrower::throwException():isNetworkConnectionAvailable');
      throw const NoNetworkError();
    } else {
      handleDioError(error);
    }
  }

  void handleDioError(dynamic error) {
    if (error is DioError) {
      logError('RemoteExceptionThrower::throwException():type: ${error.type} | response: ${error.response} | error: ${error.error}');
      if (error.response != null) {
        if (error.response!.statusCode == HttpStatus.internalServerError) {
          throw const InternalServerError();
        } else if (error.response!.statusCode == HttpStatus.badGateway) {
          throw BadGateway();
        } else if (error.response!.statusCode == HttpStatus.unauthorized) {
          throw const BadCredentialsException();
        } else {
          throw UnknownError(
              code: error.response!.statusCode,
              message: error.response!.statusMessage);
        }
      } else {
        switch (error.type) {
          case DioErrorType.connectionTimeout:
            throw ConnectionTimeout(message: error.message);
          case DioErrorType.connectionError:
            throw ConnectionError(message: error.message);
          case DioErrorType.badResponse:
            throw const BadCredentialsException();
          default:
            if (error.error is SocketException) {
              throw const SocketError();
            } else if (error.error != null) {
              throw UnknownError(message: error.error!.toString());
            } else {
              throw const UnknownError();
            }
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
      throw error;
    }
  }
}