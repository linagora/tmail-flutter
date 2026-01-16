import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GettingLabelVisibility extends LoadingState {}

class GetLabelVisibilitySuccess extends UIState {
  final bool visible;

  GetLabelVisibilitySuccess(this.visible);

  @override
  List<Object?> get props => [...super.props, visible];
}

class GetLabelVisibilityFailure extends FeatureFailure {
  GetLabelVisibilityFailure(dynamic exception) : super(exception: exception);
}
