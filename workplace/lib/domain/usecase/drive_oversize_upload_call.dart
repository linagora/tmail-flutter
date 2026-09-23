import '../entity/bridge_policy.dart';
import '../entity/workplace_access_mode.dart';
import 'workplace_call.dart';

/// Every request one oversize attachment needs, under one resolved access mode.
class DriveOversizeUploadCall extends WorkplaceCall<List<Uri>> {
  final Future<List<Uri>> Function(WorkplaceAccessMode accessMode) _transfer;

  const DriveOversizeUploadCall(this._transfer);

  @override
  BridgePolicy get bridgePolicy => BridgePolicy.never;

  @override
  Future<List<Uri>> call(WorkplaceAccessMode accessMode) => _transfer(accessMode);
}
