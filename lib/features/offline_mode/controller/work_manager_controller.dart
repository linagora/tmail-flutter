import 'dart:async';
import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/offline_mode/config/work_manager_constants.dart';
import 'package:tmail_ui_user/features/offline_mode/exceptions/workmanager_exception.dart';
import 'package:tmail_ui_user/features/offline_mode/work_manager/one_time_work_request.dart';
import 'package:tmail_ui_user/features/offline_mode/work_manager/periodic_work_request.dart';
import 'package:tmail_ui_user/features/offline_mode/work_manager/work_request.dart';
import 'package:tmail_ui_user/features/offline_mode/work_manager/worker_type.dart';
import 'package:workmanager/workmanager.dart';

class WorkManagerController {

  static WorkManagerController? _instance;

  WorkManagerController._();

  factory WorkManagerController() => _instance ??= WorkManagerController._();

  Future<void> enqueue(WorkRequest workRequest) async {
    try {
      log('WorkSchedulerController::enqueue():workRequest: $workRequest');
      if (workRequest is OneTimeWorkRequest) {
        await Workmanager().registerOneOffTask(
          workRequest.uniqueId,
          workRequest.taskId,
          tag: workRequest.tag,
          initialDelay: workRequest.initialDelay,
          constraints: workRequest.constraints,
          backoffPolicy: workRequest.backoffPolicy,
          backoffPolicyDelay: workRequest.backoffPolicyDelay,
          outOfQuotaPolicy: workRequest.outOfQuotaPolicy,
          inputData: workRequest.inputData
        );
      } if (workRequest is PeriodicWorkRequest) {
        await Workmanager().registerPeriodicTask(
          workRequest.uniqueId,
          workRequest.taskId,
          tag: workRequest.tag,
          frequency: workRequest.frequency,
          initialDelay: workRequest.initialDelay,
          constraints: workRequest.constraints,
          backoffPolicy: workRequest.backoffPolicy,
          backoffPolicyDelay: workRequest.backoffPolicyDelay,
          outOfQuotaPolicy: workRequest.outOfQuotaPolicy,
          inputData: workRequest.inputData
        );
      }
    } catch (e) {
      logError('WorkSchedulerController::enqueue(): EXCEPTION: $e');
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
          final worker = matchedType.getWorker();
          await worker.bindDI();
          final result = await worker.doWork(taskName, dataObject);
          return result;
        } else {
          return Future.error(CanNotFoundWorkerType());
        }
      } else {
        return Future.error(CanNotFoundInputData());
      }
    } catch (e) {
      logError('WorkSchedulerController::handleBackgroundTask():EXCEPTION: $e');
      return Future.error(e);
    }
  }

  Future<void> cancelByWorkType(WorkerType type) => Workmanager().cancelByTag(type.name);

  Future<void> cancelByUniqueId(String uniqueId) {
    try {
      return Workmanager().cancelByUniqueName(uniqueId);
    } catch (e) {
      logError('WorkSchedulerController::cancelByUniqueId():EXCEPTION: $e');
      return Future.value();
    }
  }

  Future<void> cancelAll() => Workmanager().cancelAll();
}