import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';

class GettingLocalSettingsState extends LoadingState {}

class GetLocalSettingsSuccess extends UIState {
  GetLocalSettingsSuccess(this.localSettingOptions);

  final LocalSettingOptions localSettingOptions;

  @override
  List<Object?> get props => [localSettingOptions];
}

class GetLocalSettingsFailure extends FeatureFailure {
  GetLocalSettingsFailure({super.exception});
}