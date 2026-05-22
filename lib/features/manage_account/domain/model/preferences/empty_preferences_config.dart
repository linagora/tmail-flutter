import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';

class EmptyPreferencesConfig extends PreferencesConfig {
  @override
  String get configKey => '';

  @override
  List<Object?> get props => [];

  @override
  Map<String, dynamic> toJson() => {};
}
