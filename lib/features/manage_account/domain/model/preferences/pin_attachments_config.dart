import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';

part 'pin_attachments_config.g.dart';

@JsonSerializable()
class PinAttachmentsConfig extends PreferencesConfig {
  final bool isEnabled;

  PinAttachmentsConfig({this.isEnabled = true});

  factory PinAttachmentsConfig.initial() => PinAttachmentsConfig();

  factory PinAttachmentsConfig.fromJson(Map<String, dynamic> json) =>
      _$PinAttachmentsConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PinAttachmentsConfigToJson(this);

  @override
  List<Object> get props => [isEnabled];
}

extension PinAttachmentsConfigExtension on PinAttachmentsConfig {
  PinAttachmentsConfig copyWith({bool? isEnabled}) {
    return PinAttachmentsConfig(
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
