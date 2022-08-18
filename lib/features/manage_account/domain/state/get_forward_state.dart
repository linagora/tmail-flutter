import 'package:core/core.dart';
import 'package:forward/forward/tmail_forward.dart';

class GetForwardSuccess extends UIState {
  final TMailForward forward;

  GetForwardSuccess(this.forward);

  @override
  List<Object?> get props => [forward];
}

class GetForwardFailure extends FeatureFailure {
  final dynamic exception;

  GetForwardFailure(this.exception);

  @override
  List<Object> get props => [exception];
}