import 'package:tmail_ui_user/features/offline_mode/hive_worker/hive_worker_queue.dart';

class OpenedEmailCacheWorkerQueue extends WorkerQueue {

  @override
  String get workerName => 'OpenedEmailCacheQueue';
}