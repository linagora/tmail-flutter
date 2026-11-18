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

  // Login whose secure write failed; keeps this run signed in until the next cold start.
  AuthenticationInfoCache? _unsavedLogin;

  // Set once the Hive box is emptied this run; later reads skip the purge.
  bool _legacyHivePurged = false;

  AuthenticationInfoCacheManager(
    this._authenticationInfoCacheClient,
    this._sessionStorageManager, {
    this._secureStorage = defaultSecureStorage,
  });

  Future<void> storeAuthenticationInfo(AuthenticationInfoCache authenticationInfoCache) async {
    final saved = await _writeOutsideHive(jsonEncode({
      _usernameField: authenticationInfoCache.username,
      _passwordField: authenticationInfoCache.password,
    }));
    if (saved) {
      _unsavedLogin = null;
      await _purgeLegacyHive();
    } else {
      _unsavedLogin = authenticationInfoCache;
    }
  }

  Future<AuthenticationInfoCache> getAuthenticationInfoStored() async {
    final unsaved = _unsavedLogin;
    if (unsaved != null) {
      return unsaved;
    }
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
    _unsavedLogin = null;
    await _removeOutsideHive();
    await _authenticationInfoCacheClient.clearAllData();
  }

  // True only when secure storage reads the value back; fss 8 on iOS can drop a write without throwing.
  Future<bool> _writeOutsideHive(String value) async {
    if (PlatformInfo.isWeb) {
      _sessionStorageManager.save(_key, value);
      return true;
    }
    try {
      await _secureStorage.write(key: _key, value: value);
      if (await _secureStorage.read(key: _key) == value) {
        return true;
      }
      logError('$runtimeType::_writeOutsideHive: secure_write_verify_failed=true');
    } catch (e, st) {
      // Login still works this run; the Hive copy is kept so the move retries on next read.
      logError('$runtimeType::_writeOutsideHive: secure_write_failed=true', exception: e, stackTrace: st);
    }
    // A failed overwrite must not leave the previous login for the next cold start.
    await _removeOutsideHive();
    return false;
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
      await _putOutsideHive(null);
    } catch (e) {
      logWarning('$runtimeType::_removeOutsideHive: $e');
      try {
        // An empty value decodes to no login, so a failed delete cannot resurrect it.
        await _putOutsideHive('');
      } catch (e) {
        logWarning('$runtimeType::_removeOutsideHive: blank_failed=true | $e');
      }
    }
  }

  // A null value removes the entry.
  Future<void> _putOutsideHive(String? value) async {
    if (PlatformInfo.isWeb) {
      value == null
          ? _sessionStorageManager.remove(_key)
          : _sessionStorageManager.save(_key, value);
    } else {
      value == null
          ? await _secureStorage.delete(key: _key)
          : await _secureStorage.write(key: _key, value: value);
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
    if (_legacyHivePurged) return;
    try {
      await _authenticationInfoCacheClient.clearAllData();
      _legacyHivePurged = true;
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
