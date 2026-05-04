import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/oauth_authorization_error.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/unknown_remote_exception.dart';

class DioNoResponseErrorHandler {
  void handle(DioException error, [StackTrace? stackTrace]) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        logWarning('RemoteExceptionThrower: connection timeout');
        throw ConnectionTimeout(message: error.message);
      case DioExceptionType.connectionError:
        logWarning('RemoteExceptionThrower: connection error');
        throw ConnectionError(message: error.message);
      default:
        _handleUnknownUnderlying(error.error, stackTrace);
    }
  }

  void _handleUnknownUnderlying(dynamic underlyingError, [StackTrace? stackTrace]) {
    if (underlyingError is SocketException) {
      logWarning('RemoteExceptionThrower: socket error');
      throw const SocketError();
    }
    if (underlyingError is OAuthAuthorizationError) {
      throw underlyingError;
    }
    _throwUnknownRemoteException(underlyingError, stackTrace);
  }

  void _throwUnknownRemoteException(dynamic underlyingError, [StackTrace? stackTrace]) {
    if (underlyingError != null) {
      logError(
        'RemoteExceptionThrower: unrecognised underlying error',
        exception: underlyingError,
        stackTrace: stackTrace,
      );
      throw UnknownRemoteException(error: underlyingError);
    }
    logError('RemoteExceptionThrower: unrecognised DioException with no response or underlying error', stackTrace: stackTrace);
    throw const UnknownRemoteException();
  }
}
