import 'dart:convert';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:tmail_ui_user/features/caching/clients/authentication_info_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

class AuthenticationInfoCacheManager extends CacheManagerInteraction {
  static const String _usernameField = 'username';
  static const String _passwordField = 'password';
  static const String _key = AuthenticationInfoCache.keyCacheValue;

  // Own iOS service: KeychainSharingManager.delete() calls deleteAll() on the shared one.
  static const FlutterSecureStorage defaultSecureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accountName: 'tmail_auth_info_store',
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  final AuthenticationInfoCacheClient _authenticationInfoCacheClient;
  final SessionStorageManager _sessionStorageManager;
  final FlutterSecureStorage _secureStorage;

  AuthenticationInfoCacheManager(
    this._authenticationInfoCacheClient,
    this._sessionStorageManager, {
    this._secureStorage = defaultSecureStorage,
  });

  Future<void> storeAuthenticationInfo(AuthenticationInfoCache authenticationInfoCache) async {
    await _writeOutsideHive(jsonEncode({
      _usernameField: authenticationInfoCache.username,
      _passwordField: authenticationInfoCache.password,
    }));
    await _purgeLegacyHive();
  }

  Future<AuthenticationInfoCache> getAuthenticationInfoStored() async {
    final stored = _decode(await _readOutsideHive());
    if (stored != null) {
      await _purgeLegacyHive();
      return stored;
    }
    final legacy = await _authenticationInfoCacheClient.getItem(_key);
    if (legacy == null) {
      throw NotFoundAuthenticationInfoCache();
    }
    // One-time move of an earlier login out of the Hive box.
    await storeAuthenticationInfo(legacy);
    return legacy;
  }

  Future<void> clear() async {
    await _removeOutsideHive();
    await _authenticationInfoCacheClient.clearAllData();
  }

  Future<void> _writeOutsideHive(String value) async {
    if (PlatformInfo.isWeb) {
      _sessionStorageManager.save(_key, value);
      return;
    }
    try {
      await _secureStorage.write(key: _key, value: value);
    } catch (e, st) {
      // Login still works this run; the user signs in again next start.
      logError('$runtimeType::_writeOutsideHive: secure_write_failed=true', exception: e, stackTrace: st);
    }
  }

  Future<String?> _readOutsideHive() async {
    try {
      return PlatformInfo.isWeb
          ? _sessionStorageManager.get(_key)
          : await _secureStorage.read(key: _key);
    } catch (_) {
      // Absent (NotFoundDataWithThisKeyException) or secure storage unavailable.
      return null;
    }
  }

  Future<void> _removeOutsideHive() async {
    try {
      if (PlatformInfo.isWeb) {
        _sessionStorageManager.remove(_key);
      } else {
        await _secureStorage.delete(key: _key);
      }
    } catch (e) {
      logWarning('$runtimeType::_removeOutsideHive: $e');
    }
  }

  AuthenticationInfoCache? _decode(String? raw) {
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthenticationInfoCache(
        json[_usernameField] as String,
        json[_passwordField] as String);
    } catch (_) {
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
