import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_detail/local_setting_detail.dart';

part 'local_setting_options.g.dart';

enum SupportedLocalSetting {
  threadDetail,
}

@JsonSerializable(converters: [LocalSettingDetailConverter()])
class LocalSettingOptions with EquatableMixin {
  const LocalSettingOptions({
    required this.settings,
  });
  
  final Map<SupportedLocalSetting, LocalSettingDetail> settings;

  factory LocalSettingOptions.fromJson(Map<String, dynamic> json) =>
      _$LocalSettingOptionsFromJson(json);

  Map<String, dynamic> toJson() => _$LocalSettingOptionsToJson(this);

  factory LocalSettingOptions.defaults() => const LocalSettingOptions(
    settings: {},
  );
  
  @override
  List<Object?> get props => [settings];
}