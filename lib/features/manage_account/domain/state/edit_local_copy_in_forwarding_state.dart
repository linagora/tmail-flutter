import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:forward/forward/tmail_forward.dart';

class EditLocalCopyInForwardingSuccess extends UIState {
  final TMailForward forward;

  EditLocalCopyInForwardingSuccess(this.forward);

  @override
  List<Object?> get props => [forward];
}

class EditLocalCopyInForwardingFailure extends FeatureFailure {
  final dynamic exception;

  EditLocalCopyInForwardingFailure(this.exception);

  @override
  List<Object> get props => [exception];
}