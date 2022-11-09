import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';

class GetQuotasSuccess extends UIState {
  final List<Quota> quotas;
  final State? state;

  GetQuotasSuccess(this.quotas, this.state);

  @override
  List<Object?> get props => [
    quotas,
    state,
  ];
}

class GetQuotasFailure extends FeatureFailure {
  final dynamic exception;

  GetQuotasFailure(this.exception);

  @override
  List<Object> get props => [exception];
}
