import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:jmap_dart_client/jmap/core/error/method/exception/error_method_response_exception.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/method_level_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/dio_no_response_error_handler.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/dio_response_error_handler.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class RemoteExceptionThrower extends ExceptionThrower {
  final _responseHandler = DioResponseErrorHandler();
  final _noResponseHandler = DioNoResponseErrorHandler();

  @override
  throwException(dynamic error, dynamic stackTrace) {
    final networkConnectionController = getBinding<NetworkConnectionController>();
    if (networkConnectionController?.isNetworkConnectionAvailable() == false) {
      logWarning('RemoteExceptionThrower::throwException():isNetworkConnectionAvailable');
      throw const NoNetworkError();
    } else {
      handleDioError(error, stackTrace);
    }
  }

  void handleDioError(dynamic error, [StackTrace? stackTrace]) {
    if (error is DioException) {
      _handleDioException(error, stackTrace);
      return;
    }

    if (error is ErrorMethodResponseException) {
      _handleMethodResponseException(error);
      return;
    }

    logError(
      'RemoteExceptionThrower::handleDioError(): unrecognised error',
      exception: error,
      stackTrace: stackTrace,
    );
    throw error;
  }

  void _handleDioException(DioException error, [StackTrace? stackTrace]) {
    logWarning(
      'RemoteExceptionThrower::_handleDioException(): type=${error.type}'
      ' status=${error.response?.statusCode}'
      ' underlying=${error.error?.runtimeType}',
    );

    if (error.error is RefreshTokenFailedException) {
      throw RefreshTokenFailedException();
    }

    final response = error.response;
    if (response != null) {
      return _responseHandler.handle(response, stackTrace);
    }

    return _noResponseHandler.handle(error, stackTrace);
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
}
