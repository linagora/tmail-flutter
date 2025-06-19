import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';

class UpdatingLocalSettingsState extends LoadingState {}

class UpdateLocalSettingsSuccess extends UIState {
  final Map<SupportedLocalSetting, LocalSettingOptions?> localSettings;

  UpdateLocalSettingsSuccess(this.localSettings);

  @override
  List<Object?> get props => [localSettings];
}

class UpdateLocalSettingsFailure extends FeatureFailure {
  UpdateLocalSettingsFailure({super.exception});
}