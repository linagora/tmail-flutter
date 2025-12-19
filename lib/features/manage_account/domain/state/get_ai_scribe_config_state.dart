import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/ai_scribe_config.dart';

class GettingAIScribeConfigState extends LoadingState {}

class GetAIScribeConfigSuccess extends UIState {
  GetAIScribeConfigSuccess(this.aiScribeConfig);

  final AIScribeConfig aiScribeConfig;

  @override
  List<Object?> get props => [aiScribeConfig];
}

class GetAIScribeConfigFailure extends FeatureFailure {
  GetAIScribeConfigFailure({super.exception});
}
