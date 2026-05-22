import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';

class GetExperimentalModeEnabledSuccess extends UIState {
  final bool isEnabled;

  GetExperimentalModeEnabledSuccess(this.isEnabled);

  @override
  List<Object> get props => [isEnabled];
}

class GetExperimentalModeEnabledFailure extends FeatureFailure {
  GetExperimentalModeEnabledFailure(dynamic exception) : super(exception: exception);
}

class EnableExperimentalModeSuccess extends UIState {
  @override
  List<Object> get props => [];
}

class EnableExperimentalModeFailure extends FeatureFailure {
  EnableExperimentalModeFailure(dynamic exception) : super(exception: exception);
}
