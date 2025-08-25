import 'package:core/presentation/state/failure.dart';
import 'package:forward/forward/tmail_forward.dart';

class UpdateForwardingCompleteWithSomeCaseFailure extends FeatureFailure {
  final TMailForward forward;

  UpdateForwardingCompleteWithSomeCaseFailure(this.forward, dynamic exception)
      : super(exception: exception);

  @override
  List<Object?> get props => [forward, ...super.props];
}
