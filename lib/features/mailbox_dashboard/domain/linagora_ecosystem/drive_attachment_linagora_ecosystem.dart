import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/empty_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_properties.dart';

part 'drive_attachment_linagora_ecosystem.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class DriveAttachmentLinagoraEcosystem extends LinagoraEcosystemProperties {
  @JsonKey(fromJson: _parseBool)
  final bool? enabled;

  DriveAttachmentLinagoraEcosystem({this.enabled});

  factory DriveAttachmentLinagoraEcosystem.fromJson(Map<String, dynamic> json) =>
      _$DriveAttachmentLinagoraEcosystemFromJson(json);

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return null;
  }

  Map<String, dynamic> toJson() => _$DriveAttachmentLinagoraEcosystemToJson(this);

  static LinagoraEcosystemProperties? deserialize(dynamic json) {
    if (json is Map<String, dynamic>) {
      return DriveAttachmentLinagoraEcosystem.fromJson(json);
    } else {
      return EmptyLinagoraEcosystem();
    }
  }

  @override
  List<Object?> get props => [enabled];
}
