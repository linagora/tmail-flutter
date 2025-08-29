import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences/preferences_root.dart';

class UpdatingLocalSettingsState extends LoadingState {}

class UpdateLocalSettingsSuccess extends UIState {
  final PreferencesRoot preferencesRoot;

  UpdateLocalSettingsSuccess(this.preferencesRoot);

  @override
  List<Object?> get props => [preferencesRoot];
}

class UpdateLocalSettingsFailure extends FeatureFailure {
  UpdateLocalSettingsFailure({super.exception});
}