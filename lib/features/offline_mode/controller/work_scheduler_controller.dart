import 'dart:async';
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
    try {
      log('WorkSchedulerController::enqueue():workRequest: $workRequest');
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
    } catch (e) {
      logError('WorkSchedulerController::enqueue(): EXCEPTION: $e');
      return Future.value();
    }
  }

  Future<bool> handleBackgroundTask(String taskName, Map<String, dynamic>? inputData) async {
    final completer = Completer<bool>();
    log('WorkSchedulerController::handleBackgroundTask():taskName: $taskName | inputData: $inputData');
    try {
      if (inputData != null && inputData.isNotEmpty) {
        final workerType = inputData.remove(WorkManagerConstants.workerTypeKey);
        final dataObject = inputData;
        log('WorkSchedulerController::handleBackgroundTask():workerType: $workerType | dataObject: $dataObject');
        final matchedType = WorkerType.values.firstWhereOrNull((type) => type.name == workerType);

        if (matchedType != null) {
          await matchedType.usingObserver().bindDI();
          await matchedType.usingObserver().observe(taskName, dataObject, completer);
        }
      }
    } catch (e) {
      completer.completeError(e);
      logError('WorkSchedulerController::handleBackgroundTask():EXCEPTION: $e');
    }
    return completer.future;
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