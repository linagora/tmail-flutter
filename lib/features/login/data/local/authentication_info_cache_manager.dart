import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/caching/clients/authentication_info_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

class AuthenticationInfoCacheManager extends CacheManagerInteraction {
  final AuthenticationInfoCacheClient _authenticationInfoCacheClient;

  AuthenticationInfoCacheManager(this._authenticationInfoCacheClient);

  Future<void> storeAuthenticationInfo(AuthenticationInfoCache authenticationInfoCache) {
    return _authenticationInfoCacheClient.insertItem(
        AuthenticationInfoCache.keyCacheValue,
        authenticationInfoCache);
  }

  Future<AuthenticationInfoCache> getAuthenticationInfoStored() async {
    final authenticationInfoCache = await _authenticationInfoCacheClient.getItem(AuthenticationInfoCache.keyCacheValue);
    if (authenticationInfoCache != null) {
      return authenticationInfoCache;
    } else {
      throw NotFoundAuthenticationInfoCache();
    }
  }

  Future<void> removeAuthenticationInfo() {
    return _authenticationInfoCacheClient.deleteItem(AuthenticationInfoCache.keyCacheValue);
  }

  @override
  Future<void> migrateHiveToIsolatedHive() async {
    try {
      final legacyMapItems = await _authenticationInfoCacheClient.getMapItems(
        isolated: false,
      );
      log('$runtimeType::migrateHiveToIsolatedHive(): Length of legacyMapItems: ${legacyMapItems.length}');
      await _authenticationInfoCacheClient.insertMultipleItem(legacyMapItems);
      log('$runtimeType::migrateHiveToIsolatedHive(): ✅ Migrate Hive box "${_authenticationInfoCacheClient.tableName}" → IsolatedHive DONE');
    } catch (e) {
      logError('$runtimeType::migrateHiveToIsolatedHive(): ❌ Migrate Hive box "${_authenticationInfoCacheClient.tableName}" → IsolatedHive FAILED, Error: $e');
    }
  }
}