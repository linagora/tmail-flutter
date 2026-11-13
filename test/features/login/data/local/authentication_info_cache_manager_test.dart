import 'dart:convert';

import 'package:core/utils/platform_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/caching/clients/authentication_info_cache_client.dart';
import 'package:tmail_ui_user/features/caching/exceptions/local_storage_exception.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

class _FakeClient extends Fake implements AuthenticationInfoCacheClient {
  AuthenticationInfoCache? item;
  int insertCalls = 0;
  int clearCalls = 0;
  int clearFailures = 0;

  @override
  Future<void> insertItem(String key, AuthenticationInfoCache newObject, {bool isolated = true}) async {
    insertCalls++;
    item = newObject;
  }

  @override
  Future<AuthenticationInfoCache?> getItem(String key, {bool isolated = true}) async => item;

  @override
  Future<void> clearAllData({bool isolated = true}) async {
    clearCalls++;
    if (clearFailures > 0) {
      clearFailures--;
      throw Exception('clear failed');
    }
    item = null;
  }
}

class _FakeSession extends Fake implements SessionStorageManager {
  final Map<String, String> values = {};

  @override
  void save(String key, String value) => values[key] = value;

  @override
  String get(String key) =>
      values[key] ?? (throw const NotFoundDataWithThisKeyException());

  @override
  void remove(String key) => values.remove(key);
}

// Any call throws UnimplementedError, which stands in for a platform failure.
class _UnavailableStorage extends Fake implements FlutterSecureStorage {}

// Write returns normally but keeps nothing, like an fss 8 iOS OSStatus result.
class _DroppingStorage extends Fake implements FlutterSecureStorage {
  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {}

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => null;
}

void main() {
  late _FakeClient client;
  late _FakeSession session;
  late AuthenticationInfoCacheManager manager;

  final info = AuthenticationInfoCache('alice@example.com', 'alice');
  const key = AuthenticationInfoCache.keyCacheValue;

  setUp(() {
    client = _FakeClient();
    session = _FakeSession();
    FlutterSecureStorage.setMockInitialValues({});
    manager = AuthenticationInfoCacheManager(client, session, secureStorage: const FlutterSecureStorage());
  });

  tearDown(() => PlatformInfo.isTestingForWeb = false);

  group('web', () {
    setUp(() => PlatformInfo.isTestingForWeb = true);

    test('store keeps the login in session storage and empties the Hive box', () async {
      client.item = info;

      await manager.storeAuthenticationInfo(info);

      expect(session.values.containsKey(key), isTrue);
      expect(client.insertCalls, 0);
      expect(client.item, isNull);
    });

    test('get reads from session storage first and purges the Hive box', () async {
      await manager.storeAuthenticationInfo(info);
      client.clearCalls = 0;

      final result = await manager.getAuthenticationInfoStored();

      expect(result, info);
      expect(client.clearCalls, 1);
    });

    test('get retries the Hive purge after a failed store purge', () async {
      client.item = info;
      client.clearFailures = 1;
      await manager.storeAuthenticationInfo(info);
      expect(client.item, info);

      await manager.getAuthenticationInfoStored();

      expect(client.item, isNull);
    });

    test('get moves an earlier Hive login to session storage', () async {
      client.item = info;

      final result = await manager.getAuthenticationInfoStored();

      expect(result, info);
      expect(session.values.containsKey(key), isTrue);
      expect(client.item, isNull);
    });

    test('get throws when neither store has a login', () async {
      expect(
        manager.getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );
    });

    test('get ignores a malformed session value', () async {
      session.values[key] = 'not json';
      client.item = info;

      expect(await manager.getAuthenticationInfoStored(), info);
    });

    test('clear removes the session value and empties the Hive box', () async {
      await manager.storeAuthenticationInfo(info);

      await manager.clear();

      expect(session.values.containsKey(key), isFalse);
      expect(client.item, isNull);
    });
  });

  group('mobile', () {
    const secure = FlutterSecureStorage();

    Future<AuthenticationInfoCache?> readSecure() async {
      final raw = await secure.read(key: key);
      if (raw == null) return null;
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return AuthenticationInfoCache(json['username'] as String, json['password'] as String);
    }

    test('store writes to secure storage and empties the Hive box', () async {
      client.item = info;

      await manager.storeAuthenticationInfo(info);

      expect(await readSecure(), info);
      expect(client.item, isNull);
      expect(session.values, isEmpty);
    });

    test('get reads secure storage and retries the Hive purge', () async {
      client.item = info;
      client.clearFailures = 1;
      await manager.storeAuthenticationInfo(info);
      expect(client.item, info);

      expect(await manager.getAuthenticationInfoStored(), info);

      expect(client.item, isNull);
    });

    test('get ignores a malformed secure value and migrates Hive', () async {
      await const FlutterSecureStorage().write(key: key, value: 'not json');
      client.item = info;

      expect(await manager.getAuthenticationInfoStored(), info);
      expect(await readSecure(), info);
      expect(client.item, isNull);
    });

    test('get moves an earlier Hive login to secure storage', () async {
      client.item = info;

      expect(await manager.getAuthenticationInfoStored(), info);

      expect(await readSecure(), info);
      expect(client.item, isNull);
    });

    test('get throws when neither store has a login', () async {
      expect(
        manager.getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );
    });

    test('unavailable secure storage keeps the Hive login', () async {
      manager = AuthenticationInfoCacheManager(client, session, secureStorage: _UnavailableStorage());
      client.item = info;

      expect(await manager.getAuthenticationInfoStored(), info);

      expect(client.item, info);
      expect(await manager.getAuthenticationInfoStored(), info);
    });

    test('a dropped secure write keeps the Hive login', () async {
      manager = AuthenticationInfoCacheManager(client, session, secureStorage: _DroppingStorage());
      client.item = info;

      expect(await manager.getAuthenticationInfoStored(), info);

      expect(client.item, info);
      expect(client.clearCalls, 0);
    });

    test('clear removes the secure value and empties the Hive box', () async {
      await manager.storeAuthenticationInfo(info);
      client.item = info;

      await manager.clear();

      expect(await readSecure(), isNull);
      expect(client.item, isNull);
    });
  });
}
