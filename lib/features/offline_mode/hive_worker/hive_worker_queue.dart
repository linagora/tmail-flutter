
import 'dart:async';
import 'dart:collection';

import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/offline_mode/hive_worker/hive_task.dart';

abstract class WorkerQueue<A> {

  final Queue<HiveTask<A>> queue = Queue<HiveTask<A>>();
  Completer? completer;

  String get workerName;

  Future addTask(HiveTask<A> task) {
    queue.add(task);
    log('WorkerQueue<$workerName>::addTask(): QUEUE_LENGTH: ${queue.length}');
    return _processTask();
  }

  Future _processTask() async {
    if (completer != null) {
      return completer!.future;
    }
    completer = Completer();
    if (queue.isNotEmpty) {
      final firstTask = queue.removeFirst();
      log('WorkerQueue<$workerName>::_processTask(): ${firstTask.id}');
      firstTask.execute()
        .then(_handleTaskExecuteCompleted)
        .catchError(_handleTaskExecuteError);
    } else {
      completer?.complete();
    }
    return completer!.future;
  }

  void _handleTaskExecuteCompleted(dynamic value) {
    log('WorkerQueue<$workerName>::_handleTaskExecuteCompleted():');
    completer?.complete();
    _releaseCompleter();
    if (queue.isNotEmpty) {
      _processTask();
    }
  }

  void _handleTaskExecuteError(error) {
    log('WorkerQueue<$workerName>::_handleTaskExecuteError(): $error');
    completer?.complete();
    _releaseCompleter();
    if (queue.isNotEmpty) {
      _processTask();
    }
  }

  void _releaseCompleter() {
    completer = null;
  }

  Future release() async {
    log('WorkerQueue<$workerName>::release():');
    queue.clear();
    _releaseCompleter();
  }
}