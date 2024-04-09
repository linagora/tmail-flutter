@TestOn('vm')

import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/clients/state_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/state_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/offline_mode/hive_worker/hive_task.dart';

import 'mailbox_state_worker_queue.dart';

void main() {
  late StateCacheClient stateCacheClient;
  late MailboxStateWorkerQueue workerQueue;

  setUpAll(() {
    HiveCacheConfig.instance.setUp(cachePath: Directory.current.path);
  });

  setUp(() {
    stateCacheClient = StateCacheClient();
    workerQueue = MailboxStateWorkerQueue();
  });

  HiveTask generateTask(String key, State value) {
    return HiveTask(
      id: key,
      runnable: () async {
        final stateCache = value.toStateCache(StateType.mailbox);
        await stateCacheClient.insertItem(key, stateCache);
      },
      conditionInvoked: () async {
        final listState = await stateCacheClient.getAll();
        return listState.length < 2;
      }
    );
  }

  group('mailbox_state_worker_queue test', () {
    test('stateCacheClient should contain only 2 elements when performing 4 more tasks in the queue at the same time.', () async {
      await stateCacheClient.clearAllData();
      final stateCacheStart = await stateCacheClient.getAll();
      log('main():mailbox_state_worker_queue:stateCacheStart: $stateCacheStart | Length: ${stateCacheStart.length}');
      await Future.delayed(const Duration(seconds: 5));

      await Future.wait([
        workerQueue.addTask(generateTask('Task1', State('value1'))),
        workerQueue.addTask(generateTask('Task2',  State('value2'))),
        workerQueue.addTask(generateTask('Task3',  State('value3'))),
        workerQueue.addTask(generateTask('Task4',  State('value4')))
      ], eagerError: true);

      await Future.delayed(const Duration(seconds: 5));

      await workerQueue.release();

      final stateCacheEnd = await stateCacheClient.getAll();
      log('main():mailbox_state_worker_queue::stateCacheEnd: $stateCacheEnd | Length: ${stateCacheEnd.length}');
      expect(stateCacheEnd.length, equals(2));
    });
  });

  tearDown(() async {
    await stateCacheClient.deleteBox();
  });
}