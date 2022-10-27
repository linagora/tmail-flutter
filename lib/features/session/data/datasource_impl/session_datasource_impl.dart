import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/session/data/datasource/session_datasource.dart';
import 'package:tmail_ui_user/features/session/data/network/session_api.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class SessionDataSourceImpl extends SessionDataSource {

  final SessionAPI _sessionAPI;
  final ExceptionThrower _exceptionThrower;

  SessionDataSourceImpl(this._sessionAPI, this._exceptionThrower);

  @override
  Future<Session> getSession() {
    return Future.sync(() async {
      return await _sessionAPI.getSession();
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }
}