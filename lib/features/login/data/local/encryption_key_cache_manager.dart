import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/caching/clients/encryption_key_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/login/data/model/encryption_key_cache.dart';

class EncryptionKeyCacheManager extends CacheManagerInteraction {
  final EncryptionKeyCacheClient _encryptionKeyCacheClient;

  EncryptionKeyCacheManager(this._encryptionKeyCacheClient);

  Future<void> storeEncryptionKey(EncryptionKeyCache encryptionKeyCache) {
    return _encryptionKeyCacheClient.insertItem(
        EncryptionKeyCache.keyCacheValue,
        encryptionKeyCache);
  }

  Future<EncryptionKeyCache?> getEncryptionKeyStored() {
    return _encryptionKeyCacheClient.getItem(EncryptionKeyCache.keyCacheValue);
  }

  @override
  Future<void> migrateHiveToIsolatedHive() async {
    try {
      final legacyMapItems = await _encryptionKeyCacheClient.getMapItems(
        isolated: false,
      );
      log('$runtimeType::migrateHiveToIsolatedHive(): Length of legacyMapItems: ${legacyMapItems.length}');
      await _encryptionKeyCacheClient.insertMultipleItem(legacyMapItems);
      log('$runtimeType::migrateHiveToIsolatedHive(): ✅ Migrate Hive box "${_encryptionKeyCacheClient.tableName}" → IsolatedHive DONE');
    } catch (e) {
      logError('$runtimeType::migrateHiveToIsolatedHive(): ❌ Migrate Hive box "${_encryptionKeyCacheClient.tableName}" → IsolatedHive FAILED, Error: $e');
    }
  }
}