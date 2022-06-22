import 'package:core/data/network/remote_exception_thrower.dart';
import 'package:core/domain/exceptions/remote_exception.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/session/data/datasource/session_datasource.dart';
import 'package:tmail_ui_user/features/session/data/network/session_api.dart';

class SessionDataSourceImpl extends SessionDataSource {

  final SessionAPI _sessionAPI;
  final RemoteExceptionThrower _remoteExceptionThrower;

  SessionDataSourceImpl(this._sessionAPI, this._remoteExceptionThrower);

  @override
  Future<Session> getSession() {
    return Future.sync(() async {
      return await _sessionAPI.getSession();
    }).catchError((error) {
      _remoteExceptionThrower.throwRemoteException(error, handler: (DioError error) {
        if (error.response?.statusCode == 502) {
          throw BadGateway();
        } else {
          log('SessionDataSourceImpl::getSession(): statusMessage: ${error.response?.statusMessage}');
          throw UnknownError(
              code: error.response?.statusCode,
              message: error.response?.statusMessage);
        }
      });
    });
  }
}