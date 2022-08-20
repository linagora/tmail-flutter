import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:forward/forward/tmail_forward.dart';

class AddRecipientsInForwardingSuccess extends UIState {
  final TMailForward forward;

  AddRecipientsInForwardingSuccess(this.forward);

  @override
  List<Object?> get props => [forward];
}

class AddRecipientsInForwardingFailure extends FeatureFailure {
  final dynamic exception;

  AddRecipientsInForwardingFailure(this.exception);

  @override
  List<Object> get props => [exception];
}