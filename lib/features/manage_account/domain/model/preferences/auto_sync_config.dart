import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';

class AutoSyncConfig extends PreferencesConfig {
  final bool isEnabled;

  AutoSyncConfig({
    this.isEnabled = true,
  });

  factory AutoSyncConfig.initial() => AutoSyncConfig();

  factory AutoSyncConfig.fromJson(Map<String, dynamic> json) {
    return AutoSyncConfig(
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'isEnabled': isEnabled,
  };

  @override
  List<Object> get props => [isEnabled];
}

extension AutoSyncConfigExtension on AutoSyncConfig {
  AutoSyncConfig copyWith({
    bool? isEnabled,
  }) {
    return AutoSyncConfig(
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
