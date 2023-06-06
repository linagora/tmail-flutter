import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/caching/clients/session_hive_cache_client.dart';
import 'package:tmail_ui_user/features/session/data/datasource/session_datasource.dart';
import 'package:tmail_ui_user/features/session/data/model/session_hive_obj.dart';
import 'package:tmail_ui_user/features/session/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class HiveSessionDataSourceImpl extends SessionDataSource {

  final SessionHiveCacheClient _sessionHiveCacheClient;
  final ExceptionThrower _exceptionThrower;

  HiveSessionDataSourceImpl(this._sessionHiveCacheClient, this._exceptionThrower);

  @override
  Future<Session> getSession() {
    throw UnimplementedError();
  }

  @override
  Future<void> storeSession(Session session) {
    return Future.sync(() async {
      return _sessionHiveCacheClient.insertItem(SessionHiveObj.keyValue, session.toHiveObj());
    }).catchError(_exceptionThrower.throwException);
  }
}