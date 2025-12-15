import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/oauth_authorization_error.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class RemoteExceptionThrower extends ExceptionThrower {

  @override
  throwException(dynamic error, dynamic stackTrace) {
    logError(
      'RemoteExceptionThrower::throwException():error: $error | stackTrace: $stackTrace',
      exception: error,
      stackTrace: stackTrace,
    );
    final networkConnectionController = getBinding<NetworkConnectionController>();
    if (networkConnectionController?.isNetworkConnectionAvailable() == false) {
      logWarning('RemoteExceptionThrower::throwException():isNetworkConnectionAvailable');
      throw const NoNetworkError();
    } else {
      handleDioError(error);
    }
  }

  void handleDioError(dynamic error) {
    if (error is DioException) {
      logWarning(
        'RemoteExceptionThrower::throwException():type: ${error.type} | response: ${error.response} | error: ${error.error}',
      );

      final response = error.response;
      final statusCode = response?.statusCode;

      if (response != null) {
        switch (statusCode) {
          case HttpStatus.internalServerError:
            throw const InternalServerError();
          case HttpStatus.badGateway:
            throw BadGateway();
          case HttpStatus.unauthorized:
            throw const BadCredentialsException();
          default:
            throw UnknownError(
              code: statusCode,
              message: response.statusMessage,
            );
        }
      }

      return _handleDioErrorWithoutResponse(error);
    }

    if (error is ErrorMethodResponseException) {
      final errorResponse = error.errorResponse as ErrorMethodResponse;
      if (errorResponse is CannotCalculateChangesMethodResponse) {
        throw CannotCalculateChangesMethodResponseException();
      } else {
        throw MethodLevelErrors(
          errorResponse.type,
          message: errorResponse.description,
        );
      }
    }

    throw error;
  }

  void _handleDioErrorWithoutResponse(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        throw ConnectionTimeout(message: error.message);
      case DioExceptionType.connectionError:
        throw ConnectionError(message: error.message);
      case DioExceptionType.badResponse:
        throw const BadCredentialsException();
      default:
        final underlyingError = error.error;
        if (underlyingError is SocketException) {
          throw const SocketError();
        } else if (underlyingError is OAuthAuthorizationError) {
          throw underlyingError;
        } else if (underlyingError != null) {
          throw UnknownError(message: underlyingError);
        } else {
          throw const UnknownError();
        }
    }
  }
}