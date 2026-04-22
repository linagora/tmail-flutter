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
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/method_level_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/server_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/unknown_remote_exception.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class RemoteExceptionThrower extends ExceptionThrower {

  @override
  throwException(dynamic error, dynamic stackTrace) {
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
      _handleDioException(error);
      return;
    }

    if (error is ErrorMethodResponseException) {
      _handleMethodResponseException(error);
      return;
    }

    logError(
      'RemoteExceptionThrower::handleDioError(): unrecognised error',
      exception: error,
    );
    throw error;
  }

  void _handleDioException(DioException error) {
    logWarning(
      'RemoteExceptionThrower::_handleDioException(): type=${error.type}'
      ' status=${error.response?.statusCode}'
      ' underlying=${error.error?.runtimeType}',
    );

    if (error.error is RefreshTokenFailedException) {
      throw RefreshTokenFailedException();
    }

    final response = error.response;
    final statusCode = response?.statusCode;

    if (response != null) {
      return _handleDioResponseError(response);
    }

    return _handleDioErrorWithoutResponse(error);
  }

  void _handleDioResponseError(Response response) {
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
        if (statusCode != null && statusCode >= 400 && statusCode < 500) {
          logWarning('RemoteExceptionThrower: HTTP 4xx ($statusCode)');
        } else if (statusCode != null && statusCode >= 500) {
          logWarning('RemoteExceptionThrower: HTTP 5xx ($statusCode)');
        } else {
          logError(
            'RemoteExceptionThrower: unknown HTTP status $statusCode',
            exception: exception,
          );
        }
        throw exception;
    }
  }

  void _handleMethodResponseException(ErrorMethodResponseException error) {
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

  void _handleDioErrorWithoutResponse(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        logWarning('RemoteExceptionThrower: connection timeout');
        throw ConnectionTimeout(message: error.message);
      case DioExceptionType.connectionError:
        logWarning('RemoteExceptionThrower: connection error');
        throw ConnectionError(message: error.message);
      case DioExceptionType.badResponse:
        throw const BadCredentialsException();
      default:
        final underlyingError = error.error;
        if (underlyingError is SocketException) {
          logWarning('RemoteExceptionThrower: socket error');
          throw const SocketError();
        } else if (underlyingError is OAuthAuthorizationError) {
          throw underlyingError;
        } else if (underlyingError != null) {
          logError(
            'RemoteExceptionThrower: unrecognised underlying error',
            exception: underlyingError,
          );
          throw UnknownRemoteException(error: underlyingError);
        } else {
          logError('RemoteExceptionThrower: unrecognised DioException with no response or underlying error');
          throw const UnknownRemoteException();
        }
    }
  }
}
