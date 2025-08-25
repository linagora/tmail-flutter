import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:forward/forward/tmail_forward.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';

class StartDeleteRecipientInForwarding extends UIState {}

class DeleteRecipientInForwardingSuccess extends UIState {
  final TMailForward forward;

  DeleteRecipientInForwardingSuccess(this.forward);

  @override
  List<Object?> get props => [forward];
}

class DeleteRecipientInForwardingWithSomeFailure extends UIState {
  final TMailForward forward;
  final SetMethodException exception;

  DeleteRecipientInForwardingWithSomeFailure(this.forward, this.exception);

  @override
  List<Object?> get props => [forward, exception];
}

class DeleteRecipientInForwardingFailure extends FeatureFailure {

  DeleteRecipientInForwardingFailure(dynamic exception) : super(exception: exception);
}