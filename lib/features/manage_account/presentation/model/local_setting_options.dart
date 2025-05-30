import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'local_setting_options.g.dart';

enum SupportedLocalSetting {
  threadDetail,
}

@JsonSerializable()
class LocalSettingOptions with EquatableMixin {
  const LocalSettingOptions({
    required this.settings,
  });
  
  final Map<SupportedLocalSetting, bool>? settings;

  factory LocalSettingOptions.fromJson(Map<String, dynamic> json) => _$LocalSettingOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$LocalSettingOptionsToJson(this);

  factory LocalSettingOptions.defaults() => const LocalSettingOptions(
    settings: {},
  );
  
  @override
  List<Object?> get props => [settings];
}