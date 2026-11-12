import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/caching/config/hive_key_platform_store.dart';
import 'package:tmail_ui_user/features/login/data/local/encryption_key_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/encryption_key_cache.dart';

class _FakeLegacyKeyManager extends Fake implements EncryptionKeyCacheManager {
  _FakeLegacyKeyManager({this.legacy, this.deleteThrows = false});

  final EncryptionKeyCache? legacy;
  final bool deleteThrows;
  int readCalls = 0;
  int deleteCalls = 0;

  @override
  Future<EncryptionKeyCache?> getEncryptionKeyStored() async {
    readCalls++;
    return legacy;
  }

  @override
  Future<void> deleteLegacyBox() async {
    deleteCalls++;
    if (deleteThrows) throw Exception('delete failed');
  }
}

// Any call throws UnimplementedError, which stands in for a platform failure.
class _UnavailableStorage extends Fake implements FlutterSecureStorage {}

// Write lands as a different value; models a read-back mismatch.
class _MismatchAfterWriteStorage extends Fake implements FlutterSecureStorage {
  String? value;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = invocation.memberName;
    if (name == #write) {
      value = 'other';
      return Future<void>.value();
    }
    if (name == #read) return Future<String?>.value(value);
    if (name == #delete) {
      value = null;
      return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  const storage = FlutterSecureStorage();
  const store = HiveKeyPlatformStore(storage: storage);

  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  group('HiveKeyPlatformStore.initialize', () {
    test('creates a 32-byte key and drops the legacy box on a fresh install', () async {
      final manager = _FakeLegacyKeyManager();

      final result = await store.initialize(manager);

      expect(result, isTrue);
      final stored = await storage.read(key: HiveKeyPlatformStore.keyName);
      expect(base64Decode(stored!).length, 32);
      expect(manager.deleteCalls, 1);
    });

    test('moves the legacy key unchanged and drops the legacy box', () async {
      final legacyValue = base64Encode(List<int>.generate(32, (i) => i));
      final manager = _FakeLegacyKeyManager(legacy: EncryptionKeyCache(legacyValue));

      final result = await store.initialize(manager);

      expect(result, isTrue);
      expect(await storage.read(key: HiveKeyPlatformStore.keyName), legacyValue);
      expect(manager.deleteCalls, 1);
    });

    test('keeps an existing stored key and skips the legacy read', () async {
      FlutterSecureStorage.setMockInitialValues({
        HiveKeyPlatformStore.keyName: 'existing',
      });
      final manager = _FakeLegacyKeyManager(legacy: EncryptionKeyCache('other'));

      final result = await store.initialize(manager);

      expect(result, isTrue);
      expect(await storage.read(key: HiveKeyPlatformStore.keyName), 'existing');
      expect(manager.readCalls, 0);
      expect(manager.deleteCalls, 1);
    });

    test('still succeeds when the legacy box cannot be deleted', () async {
      final manager = _FakeLegacyKeyManager(deleteThrows: true);

      expect(await store.initialize(manager), isTrue);
      expect(manager.deleteCalls, 1);
    });

    test('returns false when the platform store is unavailable', () async {
      final manager = _FakeLegacyKeyManager();

      final result = await HiveKeyPlatformStore(storage: _UnavailableStorage())
          .initialize(manager);

      expect(result, isFalse);
      expect(manager.deleteCalls, 0);
    });
  });

  group('HiveKeyPlatformStore.initialize read-back', () {
    test('clears a mismatched write and keeps the legacy box', () async {
      final legacyValue = base64Encode(List<int>.generate(32, (i) => i));
      final manager = _FakeLegacyKeyManager(legacy: EncryptionKeyCache(legacyValue));
      final mismatched = _MismatchAfterWriteStorage();

      final result = await HiveKeyPlatformStore(storage: mismatched).initialize(manager);

      expect(result, isFalse);
      expect(mismatched.value, isNull);
      expect(manager.deleteCalls, 0);
    });
  });

  group('HiveKeyPlatformStore.read', () {
    test('returns null when no key is stored', () async {
      expect(await store.read(), isNull);
    });

    test('returns the stored key bytes', () async {
      final bytes = List<int>.generate(32, (i) => 255 - i);
      FlutterSecureStorage.setMockInitialValues({
        HiveKeyPlatformStore.keyName: base64Encode(bytes),
      });

      expect(await store.read(), bytes);
    });

    test('returns null when the platform store is unavailable', () async {
      expect(await HiveKeyPlatformStore(storage: _UnavailableStorage()).read(), isNull);
    });
  });
}
