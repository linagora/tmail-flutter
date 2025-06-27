import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/caching/clients/session_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/home/data/model/session_hive_obj.dart';

class SessionCacheManager extends CacheManagerInteraction {
  final SessionHiveCacheClient _cacheClient;

  SessionCacheManager(this._cacheClient);

  Future<void> insertSession(SessionHiveObj sessionHiveObj) =>
      _cacheClient.insertItem(SessionHiveObj.keyValue, sessionHiveObj);

  Future<SessionHiveObj> getStoredSession() async {
    final sessionHiveObj = await _cacheClient.getItem(SessionHiveObj.keyValue);
    if (sessionHiveObj != null) {
      return sessionHiveObj;
    } else {
      throw NotFoundSessionException();
    }
  }

  Future<void> clear() => _cacheClient.clearAllData();

  @override
  Future<void> migrateHiveToIsolatedHive() async {
    try {
      final legacyMapItems = await _cacheClient.getMapItems(
        isolated: false,
      );
      log('$runtimeType::migrateHiveToIsolatedHive(): Length of legacyMapItems: ${legacyMapItems.length}');
      await _cacheClient.insertMultipleItem(legacyMapItems);
      log('$runtimeType::migrateHiveToIsolatedHive(): ✅ Migrate Hive box "${_cacheClient.tableName}" → IsolatedHive DONE');
    } catch (e) {
      logError('$runtimeType::migrateHiveToIsolatedHive(): ❌ Migrate Hive box "${_cacheClient.tableName}" → IsolatedHive FAILED, Error: $e');
    }
  }
}
