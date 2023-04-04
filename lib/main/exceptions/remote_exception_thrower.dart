import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/network_status_handle/presentation/network_connnection_controller.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class RemoteExceptionThrower extends ExceptionThrower {

  @override
  throwException(dynamic error) {
    logError('RemoteExceptionThrower::throwException():error: $error');
    final networkConnectionController = getBinding<NetworkConnectionController>();
    if (networkConnectionController?.isNetworkConnectionAvailable() == false) {
      logError('RemoteExceptionThrower::throwException():isNetworkConnectionAvailable');
      throw const NoNetworkError();
    } else {
      if (error is DioError) {
        logError('RemoteExceptionThrower::throwException():type: ${error.type} | response: ${error.response} | error: ${error.error}');
        switch (error.type) {
          case DioErrorType.connectionTimeout:
            throw const ConnectError();
          default:
            if (error.response?.statusCode == HttpStatus.internalServerError) {
              throw const InternalServerError();
            } else if (error.response?.statusCode == HttpStatus.badGateway) {
              throw BadGateway();
            } else if (error.response?.statusCode == HttpStatus.unauthorized) {
              throw const BadCredentialsException();
            } else if (error.error is SocketException) {
              throw const SocketError();
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
        throw error;
      }
    }
  }
}