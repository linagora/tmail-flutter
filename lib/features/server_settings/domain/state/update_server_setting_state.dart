import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';

class UpdatingServerSetting extends LoadingState {}

class UpdateServerSettingSuccess extends UIState {
  final TMailServerSettingOptions settingOption;

  UpdateServerSettingSuccess(this.settingOption);

  @override
  List<Object?> get props => [settingOption];
}

class UpdateServerSettingFailure extends FeatureFailure {
  UpdateServerSettingFailure(dynamic exception)
    : super(exception: exception);
}