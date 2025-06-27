import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/caching/manager/session_cache_manger.dart';
import 'package:tmail_ui_user/features/home/data/datasource/session_datasource.dart';
import 'package:tmail_ui_user/features/home/data/extensions/session_hive_obj_extension.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class HiveSessionDataSourceImpl extends SessionDataSource {

  final SessionCacheManager _sessionCacheManager;
  final ExceptionThrower _exceptionThrower;

  HiveSessionDataSourceImpl(this._sessionCacheManager, this._exceptionThrower);

  @override
  Future<Session> getSession() {
    throw UnimplementedError();
  }

  @override
  Future<void> storeSession(Session session) {
    return Future.sync(() async {
      return _sessionCacheManager.insertSession(session.toHiveObj());
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Session> getStoredSession() {
    return Future.sync(() async {
      final sessionHiveObj = await _sessionCacheManager.getStoredSession();
      return sessionHiveObj.toSession();
    }).catchError(_exceptionThrower.throwException);
  }
}