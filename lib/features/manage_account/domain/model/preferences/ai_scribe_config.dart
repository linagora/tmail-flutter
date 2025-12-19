import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';

part 'ai_scribe_config.g.dart';

@JsonSerializable()
class AIScribeConfig extends PreferencesConfig {
  final bool isEnabled;

  AIScribeConfig({
    this.isEnabled = true,
  });

  factory AIScribeConfig.initial() => AIScribeConfig();

  factory AIScribeConfig.fromJson(Map<String, dynamic> json) =>
      _$AIScribeConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AIScribeConfigToJson(this);

  @override
  List<Object> get props => [isEnabled];
}

extension AIScribeConfigExtension on AIScribeConfig {
  AIScribeConfig copyWith({
    bool? isEnabled,
  }) {
    return AIScribeConfig(
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
