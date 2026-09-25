import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/login/data/local/encryption_key_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/encryption_key_cache.dart';

class _InMemoryEncryptionKeyCacheManager extends Fake
    implements EncryptionKeyCacheManager {
  String? stored;

  @override
  Future<EncryptionKeyCache?> getEncryptionKeyStored() async =>
      stored == null ? null : EncryptionKeyCache(stored!);

  @override
  Future<void> storeEncryptionKey(EncryptionKeyCache encryptionKeyCache) async {
    stored = encryptionKeyCache.value;
  }

  @override
  Future<void> deleteEncryptionKeyStored() async {
    stored = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _InMemoryEncryptionKeyCacheManager legacyStore;
  late FlutterSecureStorage secureStorage;
  final config = HiveCacheConfig.instance;
  final legacyKey = base64Encode(List<int>.generate(32, (i) => i));

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    secureStorage = const FlutterSecureStorage();
    config.secureStorage = secureStorage;
    config.useSecureStorageForTesting = true;
    legacyStore = _InMemoryEncryptionKeyCacheManager();
    Get.put<EncryptionKeyCacheManager>(legacyStore);
  });

  tearDown(() {
    Get.reset();
    config.useSecureStorageForTesting = null;
  });

  test('SHOULD migrate the legacy Hive key to secure storage and delete it', () async {
    legacyStore.stored = legacyKey;

    await config.initializeEncryptionKey();

    expect(
      await secureStorage.read(key: HiveCacheConfig.secureEncryptionKeyName),
      legacyKey,
    );
    expect(legacyStore.stored, isNull);
    expect(await config.getEncryptionKey(), base64Decode(legacyKey));
  });

  test('SHOULD generate a new key in secure storage only', () async {
    await config.initializeEncryptionKey();

    final secureKey =
        await secureStorage.read(key: HiveCacheConfig.secureEncryptionKeyName);
    expect(secureKey, isNotNull);
    expect(base64Decode(secureKey!), hasLength(32));
    expect(legacyStore.stored, isNull);
  });

  test('SHOULD keep an existing secure key and drop a stale legacy copy', () async {
    FlutterSecureStorage.setMockInitialValues({
      HiveCacheConfig.secureEncryptionKeyName: legacyKey,
    });
    config.secureStorage = const FlutterSecureStorage();
    legacyStore.stored = base64Encode(List<int>.filled(32, 7));

    await config.initializeEncryptionKey();

    expect(legacyStore.stored, isNull);
    expect(await config.getEncryptionKey(), base64Decode(legacyKey));
  });

  test('SHOULD fall back to the legacy key when it is not migrated yet', () async {
    legacyStore.stored = legacyKey;

    expect(await config.getEncryptionKey(), base64Decode(legacyKey));
  });
}
