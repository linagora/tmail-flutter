import 'dart:convert';

import 'package:core/utils/platform_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

import 'authentication_info_cache_test_doubles.dart';

void main() {
  late FakeHiveLoginBox client;
  late FakeSessionStorage session;
  late AuthenticationInfoCacheManager manager;

  final info = AuthenticationInfoCache('alice@example.com', 'alice');
  const key = AuthenticationInfoCache.keyCacheValue;

  setUp(() {
    client = FakeHiveLoginBox();
    session = FakeSessionStorage();
    FlutterSecureStorage.setMockInitialValues({});
    manager = AuthenticationInfoCacheManager(client.mock, session, secureStorage: const FlutterSecureStorage());
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

    test('get reads from session storage first without another Hive purge', () async {
      await manager.storeAuthenticationInfo(info);
      client.clearCalls = 0;

      final result = await manager.getAuthenticationInfoStored();

      expect(result, info);
      expect(client.clearCalls, 0);
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
      manager = AuthenticationInfoCacheManager(client.mock, session, secureStorage: FakeSecureStorage()..isUnavailable = true);
      client.item = info;

      expect(await manager.getAuthenticationInfoStored(), info);

      expect(client.item, info);
      expect(await manager.getAuthenticationInfoStored(), info);
    });

    test('a dropped secure write keeps the Hive login', () async {
      manager = AuthenticationInfoCacheManager(client.mock, session, secureStorage: FakeSecureStorage()..dropAllWrites = true);
      client.item = info;

      expect(await manager.getAuthenticationInfoStored(), info);

      expect(client.item, info);
      expect(client.clearCalls, 0);
    });

    test('a dropped secure write on a fresh login keeps it for this run', () async {
      manager = AuthenticationInfoCacheManager(client.mock, session, secureStorage: FakeSecureStorage()..dropAllWrites = true);

      await manager.storeAuthenticationInfo(info);

      expect(await manager.getAuthenticationInfoStored(), info);
      expect(client.insertCalls, 0);
    });

    test('a dropped overwrite clears the earlier secure login', () async {
      final bob = AuthenticationInfoCache('bob@example.com', 'bob');
      final storage = FakeSecureStorage()
        ..dropAllWrites = true
        ..values[key] = jsonEncode({'username': info.username, 'password': info.password});
      manager = AuthenticationInfoCacheManager(client.mock, session, secureStorage: storage);

      await manager.storeAuthenticationInfo(bob);

      expect(await manager.getAuthenticationInfoStored(), bob);
      expect(storage.values.containsKey(key), isFalse);

      // Cold start: no stale login survives.
      manager = AuthenticationInfoCacheManager(client.mock, session, secureStorage: storage);
      expect(
        manager.getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );
    });

    test('a later successful store clears the in-memory login and purges Hive', () async {
      final storage = FakeSecureStorage()..writesToDrop = 1;
      manager = AuthenticationInfoCacheManager(client.mock, session, secureStorage: storage);
      client.item = info;
      await manager.storeAuthenticationInfo(info);
      expect(await manager.getAuthenticationInfoStored(), info);
      expect(client.item, isNull);
      expect(storage.values, isEmpty);

      await manager.storeAuthenticationInfo(info);

      expect(storage.values[key], isNotNull);

      // Stale memory would still return the login after secure storage is wiped.
      storage.values.clear();
      expect(
        manager.getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );
    });

    test('clear drops a login kept for this run', () async {
      manager = AuthenticationInfoCacheManager(client.mock, session, secureStorage: FakeSecureStorage()..dropAllWrites = true);
      await manager.storeAuthenticationInfo(info);
      expect(await manager.getAuthenticationInfoStored(), info);

      await manager.clear();

      expect(
        manager.getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );
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
