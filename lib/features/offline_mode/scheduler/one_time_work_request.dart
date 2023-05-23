
import 'package:tmail_ui_user/features/offline_mode/scheduler/work_request.dart';
import 'package:tmail_ui_user/features/offline_mode/scheduler/worker.dart';
import 'package:workmanager/workmanager.dart';

/// A WorkRequest for non-repeating work.
class OneTimeWorkRequest extends WorkRequest {
  OneTimeWorkRequest(
    Worker worker, {
    Duration initialDelay = Duration.zero,
    Duration backoffPolicyDelay = Duration.zero,
    ExistingWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    OutOfQuotaPolicy? outOfQuotaPolicy,
    Constraints? constraints
  }) : super(
    worker,
    initialDelay: initialDelay,
    backoffPolicyDelay: backoffPolicyDelay,
    existingWorkPolicy: existingWorkPolicy,
    backoffPolicy: backoffPolicy,
    outOfQuotaPolicy: outOfQuotaPolicy,
    constraints: constraints
  );
}