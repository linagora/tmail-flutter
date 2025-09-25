
import 'package:equatable/equatable.dart';
import 'package:workmanager/workmanager.dart';

/// Represents the scheduling of requests
abstract class WorkRequest with EquatableMixin {
  final String uniqueId;
  final String taskId;
  final String? tag;
  final Map<String, dynamic>? inputData;
  final Duration initialDelay;
  final Duration backoffPolicyDelay;
  final ExistingWorkPolicy? existingWorkPolicy;
  final ExistingPeriodicWorkPolicy? existingPeriodicWorkPolicy;
  final Duration? flexInterval;
  final BackoffPolicy? backoffPolicy;
  final OutOfQuotaPolicy? outOfQuotaPolicy;
  final Constraints? constraints;

  WorkRequest( {
    required this.uniqueId,
    required this.taskId,
    this.tag,
    this.inputData,
    this.initialDelay = Duration.zero,
    this.backoffPolicyDelay = Duration.zero,
    this.existingWorkPolicy,
    this.existingPeriodicWorkPolicy,
    this.flexInterval,
    this.backoffPolicy,
    this.outOfQuotaPolicy,
    this.constraints
  });

  @override
  List<Object?> get props => [
    uniqueId,
    taskId,
    tag,
    inputData,
    initialDelay,
    backoffPolicyDelay,
    existingWorkPolicy,
    existingPeriodicWorkPolicy,
    flexInterval,
    backoffPolicy,
    outOfQuotaPolicy,
    constraints
  ];
}