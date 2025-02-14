
import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:model/download/download_task_id.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/download/download_task_state.dart';

typedef UpdateDownloadTaskStateCallback = DownloadTaskState Function(DownloadTaskState currentState);

class DownloadController extends GetxController {

  final listDownloadTaskState = RxList<DownloadTaskState>();
  final hideDownloadTaskbar = RxBool(false);

  bool get notEmptyListDownloadTask => listDownloadTaskState.isNotEmpty;

  void addDownloadTask(DownloadTaskState task) {
    log('DownloadController::addDownloadTask(): ${task.taskId}');
    listDownloadTaskState.add(task);
    hideDownloadTaskbar.value = false;
  }

  void updateDownloadTaskByTaskId(
      DownloadTaskId downloadTaskId,
      UpdateDownloadTaskStateCallback updateDownloadTaskCallback,
  ) {
    final matchIndex = listDownloadTaskState
        .indexWhere((task) => task.taskId == downloadTaskId);
    if (matchIndex >= 0) {
      listDownloadTaskState[matchIndex] = updateDownloadTaskCallback(listDownloadTaskState[matchIndex]);
      listDownloadTaskState.refresh();
    }
  }

  void deleteDownloadTask(DownloadTaskId taskId) {
    log('DownloadController::deleteDownloadTask(): $taskId');
    final matchIndex = listDownloadTaskState
        .indexWhere((task) => task.taskId == taskId);
    if (matchIndex >= 0) {
      listDownloadTaskState.removeAt(matchIndex);
      listDownloadTaskState.refresh();
    }
    if (listDownloadTaskState.isEmpty) {
      hideDownloadTaskbar.value = true;
    }
  }
}