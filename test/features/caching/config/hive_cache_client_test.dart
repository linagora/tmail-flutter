@TestOn('vm')
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';

class _StringHiveCacheClient extends HiveCacheClient<String> {
  _StringHiveCacheClient(this.tableName);

  @override
  final String tableName;
}

String _tupleKey(List<String> parts) => TupleKey.byParts(parts).encodeKey;

void main() {
  late Directory tempDirectory;
  late _StringHiveCacheClient cacheClient;

  setUpAll(() async {
    tempDirectory = await Directory.systemTemp.createTemp(
      'hive_cache_client_test_',
    );
    Hive.init(tempDirectory.path);
  });

  setUp(() {
    cacheClient = _StringHiveCacheClient(
      'hive_cache_client_test_${DateTime.now().microsecondsSinceEpoch}',
    );
  });

  tearDown(() async {
    await cacheClient.deleteBox(isolated: false);
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  group('HiveCacheClient nested tuple key matching', () {
    test('getListByNestedKey only matches exact tuple suffix parts', () async {
      await cacheClient.insertMultipleItem({
        _tupleKey(['account-a', 'mailbox-1']): 'exact match',
        _tupleKey(['account-a', 'mailbox-10']): 'prefix collision',
        _tupleKey(['account-a', 'child-mailbox-1']): 'substring collision',
      }, isolated: false);

      final values = await cacheClient.getListByNestedKey(
        _tupleKey(['mailbox-1']),
        isolated: false,
      );

      expect(values, ['exact match']);
    });

    test(
      'clearAllDataContainKey only removes exact tuple suffix parts',
      () async {
        await cacheClient.insertMultipleItem({
          _tupleKey(['account-a', 'mailbox-1']): 'exact match',
          _tupleKey(['account-a', 'mailbox-10']): 'prefix collision',
          _tupleKey(['account-a', 'child-mailbox-1']): 'substring collision',
        }, isolated: false);

        await cacheClient.clearAllDataContainKey(
          _tupleKey(['mailbox-1']),
          isolated: false,
        );

        final remainingItems = await cacheClient.getMapItems(isolated: false);

        expect(
          remainingItems.values,
          unorderedEquals(['prefix collision', 'substring collision']),
        );
      },
    );
  });
}
