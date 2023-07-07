import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:forward/forward/tmail_forward.dart';

class StartDeleteRecipientInForwarding extends UIState {}

class DeleteRecipientInForwardingSuccess extends UIState {
  final TMailForward forward;

  DeleteRecipientInForwardingSuccess(this.forward);

  @override
  List<Object?> get props => [forward];
}

class DeleteRecipientInForwardingFailure extends FeatureFailure {

  DeleteRecipientInForwardingFailure(dynamic exception) : super(exception: exception);
}