import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:forward/forward/tmail_forward.dart';

class GetForwardSuccess extends UIState {
  final TMailForward forward;

  GetForwardSuccess(this.forward);

  @override
  List<Object?> get props => [forward];
}

class GetForwardFailure extends FeatureFailure {

  GetForwardFailure(dynamic exception) : super(exception: exception);
}