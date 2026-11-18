import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/caching/clients/composer_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';

void main() {
  final delegatedAccountId = AccountId(Id('12'));
  final personalAccountId = AccountId(Id('112'));
  final userName = UserName('alice@example.test');
  late Directory hiveDirectory;
  late ComposerHiveCacheClient cacheClient;

  setUpAll(() async {
    hiveDirectory = Directory.systemTemp.createTempSync('composer_hive_cache_client_test');
    await HiveCacheConfig.instance.setUp(cachePath: hiveDirectory.path);
  });

  tearDownAll(() async {
    await IsolatedHive.close();
    hiveDirectory.deleteSync(recursive: true);
  });

  setUp(() => cacheClient = ComposerHiveCacheClient());

  tearDown(() => IsolatedHive.deleteBoxFromDisk(CachingConstants.composerHiveCacheBoxName));

  Future<void> saveSnapshotOf(AccountId accountId, String composerId) => cacheClient.saveCache(
        accountId,
        userName,
        ComposerPersistentCache(email: Email(), composerId: composerId, timestampMs: 0),
      );

  Future<List<String?>> composerIdsOf(AccountId accountId) async =>
      (await cacheClient.getCache(accountId, userName)).map((cache) => cache.composerId).toList();

  group('an account id that is the end of another account id:', () {
    setUp(() async {
      await saveSnapshotOf(delegatedAccountId, 'delegated');
      await saveSnapshotOf(personalAccountId, 'personal');
    });

    test('getCache lists only the snapshots of the account asked for', () async {
      expect(await composerIdsOf(delegatedAccountId), ['delegated']);
      expect(await composerIdsOf(personalAccountId), ['personal']);
    });

    test('deleteCache removes the snapshots of its account and keeps those of the other account', () async {
      await cacheClient.deleteCache(delegatedAccountId, userName);

      expect(await composerIdsOf(delegatedAccountId), isEmpty);
      expect(await composerIdsOf(personalAccountId), ['personal']);
    });
  });
}
