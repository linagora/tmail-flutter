import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';

part 'thread_detail_config.g.dart';

@JsonSerializable()
class ThreadDetailConfig extends PreferencesConfig {
  static const keySuffix = 'THREAD';

  final bool isEnabled;

  ThreadDetailConfig({this.isEnabled = false});

  @override
  String get configKey => keySuffix;

  factory ThreadDetailConfig.initial() => ThreadDetailConfig();

  factory ThreadDetailConfig.fromJson(Map<String, dynamic> json) =>
      _$ThreadDetailConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ThreadDetailConfigToJson(this);

  @override
  List<Object> get props => [isEnabled];
}

extension ThreadDetailConfigExtension on ThreadDetailConfig {
  ThreadDetailConfig copyWith({bool? isEnabled}) {
    return ThreadDetailConfig(
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
