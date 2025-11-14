import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:get/get_connect/http/src/status/http_status.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
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
    logError('RemoteExceptionThrower::throwException():error: $error | stackTrace: $stackTrace');
    final networkConnectionController = getBinding<NetworkConnectionController>();
    if (networkConnectionController?.isNetworkConnectionAvailable() == false) {
      logError('RemoteExceptionThrower::throwException():isNetworkConnectionAvailable');
      throw const NoNetworkError();
    } else {
      handleDioError(error, stackTrace);
    }
  }

  void handleDioError(dynamic error, dynamic stackTrace) {
    if (error is DioException) {
      logError(
        'RemoteExceptionThrower::throwException():type: ${error.type} | response: ${error.response} | error: ${error.error}',
      );

      final response = error.response;
      final statusCode = response?.statusCode;

      if (response != null) {
        if (statusCode != HttpStatus.unauthorized) {
          reportToSentry(
            error,
            stackTrace,
            statusCode: statusCode,
            errorType: '$statusCode',
            errorMessage: response.statusMessage,
            source: 'Network:DioException',
          );
        }

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

      return _handleDioErrorWithoutResponse(error, stackTrace);
    }

    if (error is ErrorMethodResponseException) {
      final errorResponse = error.errorResponse as ErrorMethodResponse;

      reportToSentry(
        error,
        stackTrace,
        errorType: errorResponse.type.value,
        errorMessage: errorResponse.description,
        source: 'Network:JMAPMethodResponseException',
      );

      if (errorResponse is CannotCalculateChangesMethodResponse) {
        throw CannotCalculateChangesMethodResponseException();
      } else {
        throw MethodLevelErrors(
          errorResponse.type,
          message: errorResponse.description,
        );
      }
    }

    if (error is SetMethodException) {
      final setError = error.mapErrors.values.firstOrNull;
      reportToSentry(
        error,
        stackTrace,
        errorType: setError?.type.value,
        errorMessage: setError?.description,
        source: 'Network:JMAPSetMethodException',
      );
    } else {
      reportToSentry(error, stackTrace);
    }

    throw error;
  }

  void _handleDioErrorWithoutResponse(DioException error, dynamic stackTrace) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        reportToSentry(
          error,
          stackTrace,
          errorType: error.type.name,
          errorMessage: error.message,
          source: 'Network:DioException',
        );
        throw ConnectionTimeout(message: error.message);
      case DioExceptionType.connectionError:
        reportToSentry(
          error,
          stackTrace,
          errorType: error.type.name,
          errorMessage: error.message,
          source: 'Network:DioException',
        );
        throw ConnectionError(message: error.message);
      case DioExceptionType.badResponse:
        throw const BadCredentialsException();
      default:
        final underlyingError = error.error;
        if (underlyingError is SocketException) {
          reportToSentry(
            error,
            stackTrace,
            errorType: error.type.name,
            errorMessage: error.message,
            source: 'Network:DioException:SocketException',
          );
          throw const SocketError();
        } else if (underlyingError is OAuthAuthorizationError) {
          reportToSentry(
            error,
            stackTrace,
            statusCode: underlyingError is ServerError
                ? 500
                : underlyingError is TemporarilyUnavailable
                    ? 503
                    : null,
            errorType: underlyingError.error,
            errorMessage: underlyingError.errorDescription,
            source: 'Network:DioException:OAuthAuthorizationError',
          );
          throw underlyingError;
        } else if (underlyingError != null) {
          reportToSentry(
            error,
            stackTrace,
            errorType: error.type.name,
            errorMessage: underlyingError.toString(),
            source: 'Network:DioException:UnderlyingError',
          );
          throw UnknownError(message: underlyingError);
        } else {
          reportToSentry(error, stackTrace, errorType: error.type.name,
            errorMessage: error.toString(), source: 'Network:DioException:UnknownError',);
          throw const UnknownError();
        }
    }
  }
}