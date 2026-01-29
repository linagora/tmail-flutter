import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';

class OpenEmailInNewWindowConfig extends PreferencesConfig {
  final bool isEnabled;

  OpenEmailInNewWindowConfig({
    this.isEnabled = false,
  });

  factory OpenEmailInNewWindowConfig.initial() => OpenEmailInNewWindowConfig();

  factory OpenEmailInNewWindowConfig.fromJson(Map<String, dynamic> json) {
    return OpenEmailInNewWindowConfig(
      isEnabled: json['isEnabled'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'isEnabled': isEnabled,
  };

  @override
  List<Object> get props => [isEnabled];
}

extension OpenEmailInNewWindowConfigExtension on OpenEmailInNewWindowConfig {
  OpenEmailInNewWindowConfig copyWith({
    bool? isEnabled,
  }) {
    return OpenEmailInNewWindowConfig(
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
