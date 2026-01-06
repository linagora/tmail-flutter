import 'package:core/utils/platform_info.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';

part 'label_config.g.dart';

@JsonSerializable()
class LabelConfig extends PreferencesConfig {
  final bool isEnabled;

  LabelConfig({this.isEnabled = false});

  factory LabelConfig.initial() =>
      LabelConfig(isEnabled: PlatformInfo.isIntegrationTesting);

  factory LabelConfig.fromJson(Map<String, dynamic> json) =>
      _$LabelConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$LabelConfigToJson(this);

  @override
  List<Object> get props => [isEnabled];
}

extension LabelConfigExtension on LabelConfig {
  LabelConfig copyWith({bool? isEnabled}) {
    return LabelConfig(
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
