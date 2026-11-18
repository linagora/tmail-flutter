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
  });
}
