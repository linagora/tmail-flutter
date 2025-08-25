import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:forward/forward/tmail_forward.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';

class AddRecipientsInForwardingSuccess extends UIState {
  final TMailForward forward;

  AddRecipientsInForwardingSuccess(this.forward);

  @override
  List<Object?> get props => [forward];
}

class AddRecipientsInForwardingWithSomeFailure extends UIState {
  final TMailForward forward;
  final SetMethodException exception;

  AddRecipientsInForwardingWithSomeFailure(this.forward, this.exception);

  @override
  List<Object?> get props => [forward, exception];
}

class AddRecipientsInForwardingFailure extends FeatureFailure {

  AddRecipientsInForwardingFailure(dynamic exception) : super(exception: exception);
}

class UpdateRecipientsInForwardingFailure extends FeatureFailure {
  UpdateRecipientsInForwardingFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}