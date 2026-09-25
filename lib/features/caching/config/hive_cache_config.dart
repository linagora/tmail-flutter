import 'dart:convert';
import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v10.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v11.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v12.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v13.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v14.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v15.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v16.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v17.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v18.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v19.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v20.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v21.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v22.dart';
import 'package:tmail_ui_user/features/base/upgradeable/upgrade_hive_database_steps_v7.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/caching/config/cache_version.dart';
import 'package:tmail_ui_user/features/caching/config/fcm_isolate_name_server.dart';
import 'package:tmail_ui_user/features/login/data/local/encryption_key_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/encryption_key_cache.dart';
import 'package:tmail_ui_user/hive_registrar.g.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class HiveCacheConfig {

  HiveCacheConfig._internal();

  static final HiveCacheConfig _instance = HiveCacheConfig._internal();

  static HiveCacheConfig get instance => _instance;

  bool _isolatedAdaptersRegistered = false;
  bool _regularAdaptersRegistered = false;

  int _closeGeneration = 0;

  /// On mobile the Hive encryption key lives in the platform secure storage
  /// (Android Keystore / iOS Keychain), not in a Hive box next to the data it
  /// protects. The Keychain item stays readable after first unlock so that
  /// push notifications can be processed while the device is locked, and is
  /// never migrated to another device.
  static const String secureEncryptionKeyName = 'tmail_hive_encryption_key';

  FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  Uint8List? _cachedEncryptionKey;

  @visibleForTesting
  set secureStorage(FlutterSecureStorage storage) {
    _secureStorage = storage;
    _cachedEncryptionKey = null;
  }

  @visibleForTesting
  bool? useSecureStorageForTesting;

  bool get _useSecureStorage => useSecureStorageForTesting ?? PlatformInfo.isMobile;

  /// Bumped by every deliberate [closeHive], so an operation that started
  /// before one can tell it happened underneath.
  int get closeGeneration => _closeGeneration;

  Future<void> setUp({String? cachePath, bool isolated = true}) async {
    await initializeDatabase(databasePath: cachePath, isolated: isolated);
    _registerAdapter(isolated: isolated);
  }

  Future<void> initializeDatabase({
    String? databasePath,
    bool isolated = true,
  }) async {
    if (databasePath == null && PlatformInfo.isMobile) {
      Directory directory = await path_provider.getApplicationDocumentsDirectory();
      databasePath = directory.path;
    }

    if (databasePath == null) return;

    if (isolated) {
      await IsolatedHive.init(
        databasePath,
        isolateNameServer: const FcmIsolateNameServer(),
      );
    } else {
      Hive.init(databasePath);
    }
  }

  Future<void> onUpgradeDatabase(CachingManager cachingManager) async {
    final oldVersion = await cachingManager.getLatestVersion() ?? 0;
    const newVersion = CacheVersion.hiveDBVersion;
    log('HiveCacheConfig::onUpgradeDatabase():oldVersion: $oldVersion | newVersion: $newVersion');

    await UpgradeHiveDatabaseStepsV7(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV10(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV11(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV12(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV13(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV14(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV15(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV16(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV17(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV18(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV19(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV20(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV21(cachingManager).onUpgrade(oldVersion, newVersion);
    await UpgradeHiveDatabaseStepsV22(cachingManager).onUpgrade(oldVersion, newVersion);

    if (oldVersion != newVersion) {
      await cachingManager.storeCacheVersion(newVersion);
    }
  }

  Future<void> initializeEncryptionKey() async {
    final encryptionKeyCacheManager = getBinding<EncryptionKeyCacheManager>() ?? getBinding<EncryptionKeyCacheManager>(tag: BindingTag.isolateTag);
    if (encryptionKeyCacheManager == null) {
      log('HiveCacheConfig::_initializeEncryptionKey(): encryptionKeyCacheManager not found');
      return;
    }

    if (_useSecureStorage) {
      await _initializeSecureEncryptionKey(encryptionKeyCacheManager);
      return;
    }

    final encryptionKeyCache = await encryptionKeyCacheManager.getEncryptionKeyStored();
    if (encryptionKeyCache == null) {
      final secureKey = Hive.generateSecureKey();
      final secureKeyEncode = base64Encode(secureKey);
      log('HiveCacheConfig::_initializeEncryptionKey(): new encryption key generated');
      await encryptionKeyCacheManager.storeEncryptionKey(EncryptionKeyCache(secureKeyEncode));
    }
  }

  /// Ensures the key is in secure storage, migrating the legacy key stored in
  /// the EncryptionKeyCache box (same key, so no data has to be re-encrypted).
  /// The legacy copy is only deleted once the secure copy has been read back.
  Future<void> _initializeSecureEncryptionKey(
    EncryptionKeyCacheManager encryptionKeyCacheManager,
  ) async {
    if (await _readSecureEncryptionKey() != null) {
      final legacyKey = await encryptionKeyCacheManager.getEncryptionKeyStored();
      if (legacyKey != null) {
        await encryptionKeyCacheManager.deleteEncryptionKeyStored();
      }
      return;
    }

    final legacyKey = await encryptionKeyCacheManager.getEncryptionKeyStored();
    final keyValue = legacyKey?.value ?? base64Encode(Hive.generateSecureKey());

    if (await _writeSecureEncryptionKey(keyValue)) {
      log('HiveCacheConfig::_initializeSecureEncryptionKey(): key stored in secure storage (migrated: ${legacyKey != null})');
      if (legacyKey != null) {
        await encryptionKeyCacheManager.deleteEncryptionKeyStored();
      }
    } else if (legacyKey == null) {
      // Secure storage unavailable: keep the previous behaviour rather than
      // leaving the encrypted boxes without a key.
      logWarning('HiveCacheConfig::_initializeSecureEncryptionKey(): secure storage unavailable, falling back to Hive');
      await encryptionKeyCacheManager.storeEncryptionKey(EncryptionKeyCache(keyValue));
    }
  }

  Future<String?> _readSecureEncryptionKey() async {
    try {
      final value = await _secureStorage.read(key: secureEncryptionKeyName);
      return value?.isNotEmpty == true ? value : null;
    } catch (e) {
      logWarning('HiveCacheConfig::_readSecureEncryptionKey(): $e');
      return null;
    }
  }

  Future<bool> _writeSecureEncryptionKey(String value) async {
    try {
      await _secureStorage.write(key: secureEncryptionKeyName, value: value);
      return await _readSecureEncryptionKey() == value;
    } catch (e) {
      logWarning('HiveCacheConfig::_writeSecureEncryptionKey(): $e');
      return false;
    }
  }

  Future<Uint8List?> getEncryptionKey() async {
    if (_cachedEncryptionKey != null) return _cachedEncryptionKey;

    if (_useSecureStorage) {
      final secureKey = await _readSecureEncryptionKey();
      if (secureKey != null) {
        return _cachedEncryptionKey = base64Decode(secureKey);
      }
      // Not migrated yet (e.g. a push handled in background right after an
      // update): fall back to the legacy key below.
    }

    final encryptionKeyCacheManager = getBinding<EncryptionKeyCacheManager>() ?? getBinding<EncryptionKeyCacheManager>(tag: BindingTag.isolateTag);
    if (encryptionKeyCacheManager == null) {
      // No key → an encrypted box (incl. the OIDC token box) opens without a
      // cipher and cannot be decrypted, surfacing later as a "no token" startup
      // logout. Emit remotely so this silent root cause is observable.
      logError(
        'HiveCacheConfig::getEncryptionKey(): '
        'encryption_key_unavailable=true | reason=cache_manager_binding_missing',
        stackTrace: StackTrace.current,
      );
      return null;
    }
    var encryptionKeyCache = await encryptionKeyCacheManager.getEncryptionKeyStored();

    if (encryptionKeyCache != null) {
      log('HiveCacheConfig::getEncryptionKey(): encryption key resolved');
      final encryptionKeyDecode = base64Decode(encryptionKeyCache.value);
      return encryptionKeyDecode;
    } else {
      logError(
        'HiveCacheConfig::getEncryptionKey(): '
        'encryption_key_unavailable=true | reason=key_cache_empty',
        stackTrace: StackTrace.current,
      );
      return null;
    }
  }

  void _registerAdapter({bool isolated = true}) {
    if (isolated) {
      if (_isolatedAdaptersRegistered) return;
      _isolatedAdaptersRegistered = true;
      IsolatedHive.registerAdapters();
    } else {
      if (_regularAdaptersRegistered) return;
      _regularAdaptersRegistered = true;
      Hive.registerAdapters();
    }
  }

  Future<void> closeHive({bool isolated = true}) async {
    // Bumped before the close, so an operation this very close aborts still
    // observes it.
    _closeGeneration++;
    if (isolated) {
      await IsolatedHive.close();
    } else {
      await Hive.close();
    }
  }
}