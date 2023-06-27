
import 'package:tmail_ui_user/features/offline_mode/work_manager/work_request.dart';
import 'package:workmanager/workmanager.dart';

/// A WorkRequest for non-repeating work.
class OneTimeWorkRequest extends WorkRequest {
  OneTimeWorkRequest({
    required String uniqueId,
    required String taskId,
    String? tag,
    Map<String, dynamic>? inputData,
    Duration initialDelay = Duration.zero,
    Duration backoffPolicyDelay = Duration.zero,
    ExistingWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    OutOfQuotaPolicy? outOfQuotaPolicy,
    Constraints? constraints
  }) : super(
    uniqueId: uniqueId,
    taskId: taskId,
    tag: tag,
    inputData: inputData,
    initialDelay: initialDelay,
    backoffPolicyDelay: backoffPolicyDelay,
    existingWorkPolicy: existingWorkPolicy,
    backoffPolicy: backoffPolicy,
    outOfQuotaPolicy: outOfQuotaPolicy,
    constraints: constraints
  );
}