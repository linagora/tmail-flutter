import 'dart:async';
import 'dart:convert';

import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

import 'authentication_info_cache_test_doubles.dart';

void main() {
  const key = AuthenticationInfoCache.keyCacheValue;
  final alice = AuthenticationInfoCache('alice@example.com', 'alice-pw');
  final bob = AuthenticationInfoCache('bob@example.com', 'bob-pw');
  late FakeHiveLoginBox client;
  late FakeSecureStorage storage;

  setUp(() {
    PlatformInfo.isTestingForWeb = false;
    client = FakeHiveLoginBox();
    storage = FakeSecureStorage();
  });

  AuthenticationInfoCacheManager newManager() =>
      AuthenticationInfoCacheManager(client.mock, FakeSessionStorage(), secureStorage: storage);

  group('mobile secure login', () {
    test('a throwing overwrite does not leave the previous account for the next cold start', () async {
      storage.values[key] = jsonEncode({'username': alice.username, 'password': alice.password});
      storage.throwOnWrite = true;
      final manager = newManager();

      await manager.storeAuthenticationInfo(bob);
      expect(await manager.getAuthenticationInfoStored(), bob);

      // Cold start: the old account must not come back for downloads.
      expect(
        newManager().getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );
    });

    test('a dropped new login does not leave the earlier Hive login for the next cold start', () async {
      client.item = alice;
      storage.dropAllWrites = true;

      await newManager().storeAuthenticationInfo(bob);

      expect(client.item, isNull);
      expect(
        newManager().getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );
    });

    test('repeated reads clear the Hive box at most once', () async {
      await newManager().storeAuthenticationInfo(alice);
      final manager = newManager();
      client.clearCalls = 0;

      await manager.getAuthenticationInfoStored();
      await manager.getAuthenticationInfoStored();
      await manager.getAuthenticationInfoStored();

      expect(client.clearCalls, lessThanOrEqualTo(1));
    });

    test('a throwing delete on logout still leaves no login for the next cold start', () async {
      await newManager().storeAuthenticationInfo(alice);
      storage.throwOnDelete = true;

      await newManager().clear();

      expect(
        newManager().getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );
    });

    test('a delete that reports success but keeps the login still logs out', () async {
      await newManager().storeAuthenticationInfo(alice);
      storage.dropDeletes = true;

      await newManager().clear();

      expect(
        newManager().getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );
    });

    test('a Hive read pending during logout does not move the login back', () async {
      client.item = alice;
      client.holdGet = Completer<void>();
      final manager = newManager();

      final pending = manager.getAuthenticationInfoStored();
      await manager.clear();
      client.holdGet!.complete();

      await expectLater(pending, throwsA(isA<NotFoundAuthenticationInfoCache>()));
      expect(
        newManager().getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );
    });

    test('a secure write pending during logout does not persist the login', () async {
      client.item = alice;
      storage.holdWrite = Completer<void>();
      final manager = newManager();

      final pending = manager.getAuthenticationInfoStored();
      await pumpEventQueue();
      await manager.clear();
      storage.holdWrite!.complete();

      await expectLater(pending, throwsA(isA<NotFoundAuthenticationInfoCache>()));
      expect(storage.values.containsKey(key), isFalse);
      expect(
        manager.getAuthenticationInfoStored(),
        throwsA(isA<NotFoundAuthenticationInfoCache>()),
      );
    });
  });
}
