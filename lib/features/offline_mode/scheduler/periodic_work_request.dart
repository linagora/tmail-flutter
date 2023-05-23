
import 'package:tmail_ui_user/features/offline_mode/scheduler/work_request.dart';
import 'package:tmail_ui_user/features/offline_mode/scheduler/worker.dart';
import 'package:workmanager/workmanager.dart';

/// A WorkRequest for repeating work.
class PeriodicWorkRequest extends WorkRequest {
  final Duration? frequency;

  PeriodicWorkRequest(
    Worker worker, {
    Duration initialDelay = Duration.zero,
    Duration backoffPolicyDelay = Duration.zero,
    ExistingWorkPolicy? existingWorkPolicy,
    BackoffPolicy? backoffPolicy,
    OutOfQuotaPolicy? outOfQuotaPolicy,
    Constraints? constraints,
    this.frequency
  }) : super(
    worker,
    initialDelay: initialDelay,
    backoffPolicyDelay: backoffPolicyDelay,
    existingWorkPolicy: existingWorkPolicy,
    backoffPolicy: backoffPolicy,
    outOfQuotaPolicy: outOfQuotaPolicy,
    constraints: constraints
  );

  @override
  List<Object?> get props => [super.props, frequency];
}