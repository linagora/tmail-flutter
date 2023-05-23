
import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/offline_mode/scheduler/one_time_work_request.dart';
import 'package:tmail_ui_user/features/offline_mode/scheduler/periodic_work_request.dart';
import 'package:tmail_ui_user/features/offline_mode/scheduler/work_request.dart';
import 'package:tmail_ui_user/features/offline_mode/scheduler/worker_type.dart';
import 'package:workmanager/workmanager.dart';

class WorkSchedulerController {

  static WorkSchedulerController? _instance;

  WorkSchedulerController._();

  factory WorkSchedulerController() => _instance ??= WorkSchedulerController._();

  Future<void> enqueue(WorkRequest workRequest) {
    if (workRequest is OneTimeWorkRequest) {
      return Workmanager().registerOneOffTask(
        workRequest.worker.uniqueId,
        workRequest.worker.id,
        tag: workRequest.worker.type.name,
        initialDelay: workRequest.initialDelay,
        constraints: workRequest.constraints,
        backoffPolicy: workRequest.backoffPolicy,
        backoffPolicyDelay: workRequest.backoffPolicyDelay,
        outOfQuotaPolicy: workRequest.outOfQuotaPolicy,
        inputData: workRequest.worker.inputData
      );
    } if (workRequest is PeriodicWorkRequest) {
      return Workmanager().registerPeriodicTask(
        workRequest.worker.uniqueId,
        workRequest.worker.id,
        frequency: workRequest.frequency,
        tag: workRequest.worker.type.name,
        initialDelay: workRequest.initialDelay,
        constraints: workRequest.constraints,
        backoffPolicy: workRequest.backoffPolicy,
        backoffPolicyDelay: workRequest.backoffPolicyDelay,
        outOfQuotaPolicy: workRequest.outOfQuotaPolicy,
        inputData: workRequest.worker.inputData
      );
    } else {
      return Future.value();
    }
  }

  Future<bool> handleBackgroundTask(String taskName, Map<String, dynamic>? inputData) {
    if (inputData != null && inputData.isNotEmpty) {
      final typeTask = inputData['workerType'];
      final dataObject = inputData['data'];
      log('WorkSchedulerController::handleBackgroundTask():typeTask: $typeTask | dataObject: $dataObject');
      final workType = WorkerType.values.firstWhereOrNull((type) => type.name == typeTask);
      log('WorkSchedulerController::handleBackgroundTask():workType: $workType');
    }

    return Future.value(true);
  }

  Future<void> cancelByWorkType(WorkerType type) => Workmanager().cancelByTag(type.name);

  Future<void> cancelByUniqueId(String uniqueId) => Workmanager().cancelByUniqueName(uniqueId);

  Future<void> cancelAll() => Workmanager().cancelAll();
}