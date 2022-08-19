import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:forward/forward/tmail_forward.dart';

class StartDeleteRecipientInForwarding extends UIState {

  StartDeleteRecipientInForwarding();

  @override
  List<Object?> get props => [];
}

class DeleteRecipientInForwardingSuccess extends UIState {
  final TMailForward forward;

  DeleteRecipientInForwardingSuccess(this.forward);

  @override
  List<Object?> get props => [forward];
}

class DeleteRecipientInForwardingFailure extends FeatureFailure {
  final dynamic exception;

  DeleteRecipientInForwardingFailure(this.exception);

  @override
  List<Object> get props => [exception];
}