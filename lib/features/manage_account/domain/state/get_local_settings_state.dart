import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences/preferences_root.dart';

class GettingLocalSettingsState extends LoadingState {}

class GetLocalSettingsSuccess extends UIState {
  GetLocalSettingsSuccess(this.preferencesRoot);

  final PreferencesRoot preferencesRoot;

  @override
  List<Object?> get props => [preferencesRoot];
}

class GetLocalSettingsFailure extends FeatureFailure {
  GetLocalSettingsFailure({super.exception});
}