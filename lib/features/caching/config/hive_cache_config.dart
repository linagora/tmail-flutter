import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
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
    final encryptionKeyCache = await encryptionKeyCacheManager.getEncryptionKeyStored();
    if (encryptionKeyCache == null) {
      final secureKey = Hive.generateSecureKey();
      final secureKeyEncode = base64Encode(secureKey);
      log('HiveCacheConfig::_initializeEncryptionKey(): secureKeyEncode: $secureKeyEncode');
      await encryptionKeyCacheManager.storeEncryptionKey(EncryptionKeyCache(secureKeyEncode));
    }
  }

  Future<Uint8List?> getEncryptionKey() async {
    final encryptionKeyCacheManager = getBinding<EncryptionKeyCacheManager>() ?? getBinding<EncryptionKeyCacheManager>(tag: BindingTag.isolateTag);
    if (encryptionKeyCacheManager == null) {
      log('HiveCacheConfig::getEncryptionKey(): encryptionKeyCacheManager not found');
      return null;
    }
    var encryptionKeyCache = await encryptionKeyCacheManager.getEncryptionKeyStored();

    if (encryptionKeyCache != null) {
      final encryptionKey = encryptionKeyCache.value;
      log('HiveCacheConfig::getEncryptionKey(): encryptionKey: $encryptionKey');
      final encryptionKeyDecode = base64Decode(encryptionKeyCache.value);
      return encryptionKeyDecode;
    } else {
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
    if (isolated) {
      await IsolatedHive.close();
    } else {
      await Hive.close();
    }
  }
}