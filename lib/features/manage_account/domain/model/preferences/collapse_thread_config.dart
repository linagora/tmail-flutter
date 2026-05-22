import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';

part 'collapse_thread_config.g.dart';

@JsonSerializable()
class CollapseThreadConfig extends PreferencesConfig {
  static const keySuffix = 'COLLAPSE_THREAD';

  final bool isEnabled;

  CollapseThreadConfig({this.isEnabled = false});

  @override
  String get configKey => keySuffix;

  factory CollapseThreadConfig.initial() => CollapseThreadConfig();

  factory CollapseThreadConfig.fromJson(Map<String, dynamic> json) =>
      _$CollapseThreadConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CollapseThreadConfigToJson(this);

  @override
  List<Object> get props => [isEnabled];
}

extension CollapseThreadConfigExtension on CollapseThreadConfig {
  CollapseThreadConfig copyWith({bool? isEnabled}) {
    return CollapseThreadConfig(
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
