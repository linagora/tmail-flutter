import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:forward/forward/tmail_forward.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';

class EditLocalCopyInForwardingSuccess extends UIState {
  final TMailForward forward;

  EditLocalCopyInForwardingSuccess(this.forward);

  @override
  List<Object?> get props => [forward];
}

class EditLocalCopyInForwardingWithSomeFailure extends UIState {
  final TMailForward forward;
  final SetMethodException exception;

  EditLocalCopyInForwardingWithSomeFailure(this.forward, this.exception);

  @override
  List<Object?> get props => [forward, exception];
}

class EditLocalCopyInForwardingFailure extends FeatureFailure {

  EditLocalCopyInForwardingFailure(dynamic exception) : super(exception: exception);
}