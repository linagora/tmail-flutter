import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';

class GettingLocalSettingsState extends LoadingState {}

class GetLocalSettingsSuccess extends UIState {
  GetLocalSettingsSuccess(this.preferencesSetting);

  final PreferencesSetting preferencesSetting;

  @override
  List<Object?> get props => [preferencesSetting];
}

class GetLocalSettingsFailure extends FeatureFailure {
  GetLocalSettingsFailure({super.exception});
}