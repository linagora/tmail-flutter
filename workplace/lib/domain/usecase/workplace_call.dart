import '../entity/bridge_policy.dart';
import '../entity/workplace_access_mode.dart';

/// One Workplace call plus the transport it can ride.
abstract class WorkplaceCall<T> {
  const WorkplaceCall();

  BridgePolicy get bridgePolicy;

  Future<T> call(WorkplaceAccessMode accessMode);
}
