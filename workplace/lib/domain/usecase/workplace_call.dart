import '../entity/workplace_access_mode.dart';

/// One Workplace call plus the transport it can ride.
abstract class WorkplaceCall<T> {
  const WorkplaceCall();

  /// `false` skips the bridge when it has no implementation for this call.
  bool get supportsBridge;

  /// `true` retries over bearer token when the bridge call throws; only for idempotent calls.
  bool get fallsBackToBearer => false;

  Future<T> call(WorkplaceAccessMode accessMode);
}
