import 'dart:convert';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/features/caching/clients/authentication_info_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

class AuthenticationInfoCacheManager extends CacheManagerInteraction {
  static const String _usernameField = 'username';
  static const String _passwordField = 'password';

  final AuthenticationInfoCacheClient _authenticationInfoCacheClient;
  final SessionStorageManager _sessionStorageManager;

  AuthenticationInfoCacheManager(
    this._authenticationInfoCacheClient,
    this._sessionStorageManager,
  );

  Future<void> storeAuthenticationInfo(AuthenticationInfoCache authenticationInfoCache) async {
    if (!PlatformInfo.isWeb) {
      return _authenticationInfoCacheClient.insertItem(
          AuthenticationInfoCache.keyCacheValue,
          authenticationInfoCache);
    }
    _sessionStorageManager.save(
      AuthenticationInfoCache.keyCacheValue,
      jsonEncode({
        _usernameField: authenticationInfoCache.username,
        _passwordField: authenticationInfoCache.password,
      }));
    await _purgeLegacyHive();
  }

  Future<AuthenticationInfoCache> getAuthenticationInfoStored() async {
    if (PlatformInfo.isWeb) {
      final fromSession = _readFromSession();
      if (fromSession != null) {
        await _purgeLegacyHive();
        return fromSession;
      }
    }
    final authenticationInfoCache = await _authenticationInfoCacheClient.getItem(AuthenticationInfoCache.keyCacheValue);
    if (authenticationInfoCache == null) {
      throw NotFoundAuthenticationInfoCache();
    }
    if (PlatformInfo.isWeb) {
      // One-time move of an earlier web login out of IndexedDB.
      await storeAuthenticationInfo(authenticationInfoCache);
    }
    return authenticationInfoCache;
  }

  Future<void> clear() async {
    if (PlatformInfo.isWeb) {
      _sessionStorageManager.remove(AuthenticationInfoCache.keyCacheValue);
    }
    await _authenticationInfoCacheClient.clearAllData();
  }

  AuthenticationInfoCache? _readFromSession() {
    try {
      final json = jsonDecode(_sessionStorageManager.get(AuthenticationInfoCache.keyCacheValue)) as Map<String, dynamic>;
      return AuthenticationInfoCache(
        json[_usernameField] as String,
        json[_passwordField] as String);
    } catch (_) {
      // Absent (NotFoundDataWithThisKeyException) or malformed.
      return null;
    }
  }

  Future<void> _purgeLegacyHive() async {
    try {
      await _authenticationInfoCacheClient.clearAllData();
    } catch (e) {
      logWarning('$runtimeType::_purgeLegacyHive: $e');
    }
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
      logWarning('$runtimeType::migrateHiveToIsolatedHive(): ❌ Migrate Hive box "${_authenticationInfoCacheClient.tableName}" → IsolatedHive FAILED, Error: $e');
    }
  }
}
