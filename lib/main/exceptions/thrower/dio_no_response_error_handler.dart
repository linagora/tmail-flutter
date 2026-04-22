import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/oauth_authorization_error.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/unknown_remote_exception.dart';

class DioNoResponseErrorHandler {
  void handle(DioException error) {
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
        _handleUnknownUnderlying(error.error);
    }
  }

  void _handleUnknownUnderlying(dynamic underlyingError) {
    if (underlyingError is SocketException) {
      logWarning('RemoteExceptionThrower: socket error');
      throw const SocketError();
    }
    if (underlyingError is OAuthAuthorizationError) {
      throw underlyingError;
    }
    _throwUnknownRemoteException(underlyingError);
  }

  void _throwUnknownRemoteException(dynamic underlyingError) {
    if (underlyingError != null) {
      logError(
        'RemoteExceptionThrower: unrecognised underlying error',
        exception: underlyingError,
      );
      throw UnknownRemoteException(error: underlyingError);
    }
    logError('RemoteExceptionThrower: unrecognised DioException with no response or underlying error');
    throw const UnknownRemoteException();
  }
}
