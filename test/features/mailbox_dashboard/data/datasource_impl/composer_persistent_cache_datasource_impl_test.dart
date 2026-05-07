import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/caching/clients/composer_hive_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource_impl/composer_persistent_cache_datasource_impl.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/exception_thrower.dart';

import 'composer_persistent_cache_datasource_impl_test.mocks.dart';

@GenerateMocks([ComposerHiveCacheClient, ExceptionThrower])
void main() {
  late MockComposerHiveCacheClient mockCacheClient;
  late MockExceptionThrower mockExceptionThrower;
  late ComposerPersistentCacheDatasourceImpl datasource;

  final accountId = AccountId(Id('account-1'));
  final userName = UserName('user@example.com');

  setUp(() {
    mockCacheClient = MockComposerHiveCacheClient();
    mockExceptionThrower = MockExceptionThrower();
    datasource = ComposerPersistentCacheDatasourceImpl(
      mockCacheClient,
      mockExceptionThrower,
    );
  });

  group('saveComposerCache', () {
    test('delegates to cache client', () async {
      final cache = ComposerCache(composerId: 'id-1');
      when(mockCacheClient.saveCache(accountId, userName, cache))
          .thenAnswer((_) async {});

      await datasource.saveComposerCache(accountId, userName, cache);

      verify(mockCacheClient.saveCache(accountId, userName, cache)).called(1);
    });
  });

  group('getComposerCache', () {
    test('delegates to cache client', () async {
      when(mockCacheClient.getCache(accountId, userName))
          .thenAnswer((_) async => []);

      final result = await datasource.getComposerCache(accountId, userName);

      expect(result, isEmpty);
      verify(mockCacheClient.getCache(accountId, userName)).called(1);
    });
  });

  group('removeAllComposerCache', () {
    test('delegates to cache client', () async {
      when(mockCacheClient.deleteCache(accountId, userName))
          .thenAnswer((_) async {});

      await datasource.removeAllComposerCache(accountId, userName);

      verify(mockCacheClient.deleteCache(accountId, userName)).called(1);
    });
  });
}
