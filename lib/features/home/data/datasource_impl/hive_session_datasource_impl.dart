import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/session_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/home/data/datasource/session_datasource.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/home/data/extensions/session_hive_obj_extension.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
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
  Future<void> storeSession(Session session, AccountId accountId, UserName userName) {
    return Future.sync(() async {
      final sessionKey = TupleKey(accountId.asString, userName.value).encodeKey;
      return _sessionHiveCacheClient.insertItem(
        sessionKey,
        session.toHiveObj()
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Session> getStoredSession(AccountId accountId, UserName userName) {
    return Future.sync(() async {
      final sessionKey = TupleKey(accountId.asString, userName.value).encodeKey;
      final sessionHiveObj = await _sessionHiveCacheClient.getItem(sessionKey);
      if (sessionHiveObj != null) {
        return sessionHiveObj.toSession();
      } else {
        throw NotFoundSessionException();
      }
    }).catchError(_exceptionThrower.throwException);
  }
}