import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/converters/default_preferences_config_converter.dart';

class DefaultPreferencesConfig extends PreferencesConfig {
  final dynamic data;

  DefaultPreferencesConfig(this.data);

  factory DefaultPreferencesConfig.fromJson(Map<String, dynamic> json) =>
      const DefaultPreferencesConfigConverter().fromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      const DefaultPreferencesConfigConverter().toJson(this);

  @override
  List<Object?> get props => [data];
}
