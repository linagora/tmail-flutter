import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/default_preferences_config.dart';

class DefaultPreferencesConfigConverter
    implements JsonConverter<DefaultPreferencesConfig, Map<String, dynamic>> {
  const DefaultPreferencesConfigConverter();

  @override
  DefaultPreferencesConfig fromJson(Map<String, dynamic> json) =>
      DefaultPreferencesConfig(json);

  @override
  Map<String, dynamic> toJson(DefaultPreferencesConfig config) => config.data;
}
