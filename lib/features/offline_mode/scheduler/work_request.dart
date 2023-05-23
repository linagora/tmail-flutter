
import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/offline_mode/scheduler/worker.dart';
import 'package:workmanager/workmanager.dart';

/// Represents the scheduling of requests
abstract class WorkRequest with EquatableMixin {
  final Worker worker;
  final Duration initialDelay;
  final Duration backoffPolicyDelay;
  final ExistingWorkPolicy? existingWorkPolicy;
  final BackoffPolicy? backoffPolicy;
  final OutOfQuotaPolicy? outOfQuotaPolicy;
  final Constraints? constraints;

  WorkRequest(
    this.worker,
    {
      this.initialDelay = Duration.zero,
      this.backoffPolicyDelay = Duration.zero,
      this.existingWorkPolicy,
      this.backoffPolicy,
      this.outOfQuotaPolicy,
      this.constraints
    }
  );

  @override
  List<Object?> get props => [
    worker,
    initialDelay,
    backoffPolicyDelay,
    existingWorkPolicy,
    backoffPolicy,
    outOfQuotaPolicy,
    constraints
  ];
}