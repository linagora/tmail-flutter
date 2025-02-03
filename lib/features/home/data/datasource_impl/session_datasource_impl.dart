import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/home/data/datasource/session_datasource.dart';
import 'package:tmail_ui_user/features/home/data/network/session_api.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class SessionDataSourceImpl extends SessionDataSource {

  final SessionAPI _sessionAPI;
  final ExceptionThrower _exceptionThrower;

  SessionDataSourceImpl(this._sessionAPI, this._exceptionThrower);

  @override
  Future<Session> getSession() {
    return Future.sync(() async {
      return await _sessionAPI.getSession(
        converters: SessionExtensions.customMapCapabilitiesConverter,
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> storeSession(Session session) {
    throw UnimplementedError();
  }

  @override
  Future<Session> getStoredSession() {
    throw UnimplementedError();
  }
}