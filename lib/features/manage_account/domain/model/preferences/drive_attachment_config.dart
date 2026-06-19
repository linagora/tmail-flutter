import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';

part 'drive_attachment_config.g.dart';

@JsonSerializable()
class DriveAttachmentConfig extends PreferencesConfig {
  static const keySuffix = 'DRIVE_ATTACHMENT';

  final bool isEnabled;

  DriveAttachmentConfig({
    this.isEnabled = false,
  });

  @override
  String get configKey => keySuffix;

  factory DriveAttachmentConfig.initial() => DriveAttachmentConfig();

  factory DriveAttachmentConfig.fromJson(Map<String, dynamic> json) =>
      _$DriveAttachmentConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$DriveAttachmentConfigToJson(this);

  @override
  List<Object> get props => [isEnabled];
}

extension DriveAttachmentConfigExtension on DriveAttachmentConfig {
  DriveAttachmentConfig copyWith({bool? isEnabled}) {
    return DriveAttachmentConfig(
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
