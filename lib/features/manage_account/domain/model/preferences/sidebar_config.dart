import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';

class SidebarConfig extends PreferencesConfig {
  final bool isExpanded;

  SidebarConfig({
    this.isExpanded = true,
  });

  factory SidebarConfig.initial() => SidebarConfig();

  factory SidebarConfig.fromJson(Map<String, dynamic> json) {
    return SidebarConfig(
      isExpanded: json['isExpanded'] as bool? ?? true,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'isExpanded': isExpanded,
  };

  @override
  List<Object> get props => [isExpanded];
}

extension SidebarConfigExtension on SidebarConfig {
  SidebarConfig copyWith({
    bool? isExpanded,
  }) {
    return SidebarConfig(
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}
