import 'package:tmail_ui_user/features/caching/encryption_key_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/encryption_key_cache.dart';

class EncryptionKeyCacheManager {
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
}