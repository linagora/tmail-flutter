import 'dart:convert';

import 'package:core/utils/platform_info.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/caching/clients/authentication_info_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/session_storage_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

class _Client extends Fake implements AuthenticationInfoCacheClient {
  AuthenticationInfoCache? item;
  int insertCalls = 0;
  int clearCalls = 0;

  @override
  Future<void> insertItem(String key, AuthenticationInfoCache o, {bool isolated = true}) async {
    insertCalls++;
    item = o;
  }

  @override
  Future<AuthenticationInfoCache?> getItem(String key, {bool isolated = true}) async => item;

  @override
  Future<void> clearAllData({bool isolated = true}) async {
    clearCalls++;
    item = null;
  }
}

class _Session extends Fake implements SessionStorageManager {}

class _Storage extends Fake implements FlutterSecureStorage {
  final Map<String, String> values = {};
  bool throwOnWrite = false;
  bool throwOnDelete = false;

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
  }) async {
    if (throwOnWrite) throw Exception('keystore unavailable');
    values[key] = value!;
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => values[key];

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (throwOnDelete) throw Exception('delete failed');
    values.remove(key);
  }
}

void main() {
  const key = AuthenticationInfoCache.keyCacheValue;
  final alice = AuthenticationInfoCache('alice@example.com', 'alice-pw');
  final bob = AuthenticationInfoCache('bob@example.com', 'bob-pw');
  late _Client client;
  late _Storage storage;

  setUp(() {
    PlatformInfo.isTestingForWeb = false;
    client = _Client();
    storage = _Storage();
  });

  AuthenticationInfoCacheManager newManager() =>
      AuthenticationInfoCacheManager(client, _Session(), secureStorage: storage);

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
  });
}
