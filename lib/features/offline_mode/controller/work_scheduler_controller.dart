
import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/offline_mode/config/work_manager_constants.dart';
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

  Future<bool> handleBackgroundTask(String taskName, Map<String, dynamic>? inputData) async {
    log('WorkSchedulerController::handleBackgroundTask():taskName: $taskName | inputData: $inputData');
    try {
      if (inputData != null && inputData.isNotEmpty) {
        final workerType = inputData.remove(WorkManagerConstants.workerTypeKey);
        final dataObject = inputData;
        log('WorkSchedulerController::handleBackgroundTask():workerType: $workerType | dataObject: $dataObject');
        final matchedType = WorkerType.values.firstWhereOrNull((type) => type.name == workerType);

        if (matchedType != null) {
          await matchedType.usingObserver().bindDI();
          await matchedType.usingObserver().observe(taskName, dataObject);
        }
      }
    } catch (e) {
      logError('WorkSchedulerController::handleBackgroundTask():EXCEPTION: $e');
    }
    return Future.value(true);
  }

  Future<void> cancelByWorkType(WorkerType type) => Workmanager().cancelByTag(type.name);

  Future<void> cancelByUniqueId(String uniqueId) => Workmanager().cancelByUniqueName(uniqueId);

  Future<void> cancelAll() => Workmanager().cancelAll();
}