import '../entity/workplace_access_mode.dart';

/// One Workplace call plus the transport it can ride.
abstract class WorkplaceAction<T> {
  const WorkplaceAction();

  /// `false` skips the bridge when it has no implementation for this call.
  bool get supportsBridge;

  Future<T> call(WorkplaceAccessMode accessMode);
}
