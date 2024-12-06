
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_properties.dart';

part 'empty_linagora_ecosystem.g.dart';

@JsonSerializable()
class EmptyLinagoraEcosystem extends LinagoraEcosystemProperties {

  EmptyLinagoraEcosystem();

  factory EmptyLinagoraEcosystem.fromJson(Map<String, dynamic> json) => _$EmptyLinagoraEcosystemFromJson(json);

  Map<String, dynamic> toJson() => _$EmptyLinagoraEcosystemToJson(this);

  @override
  List<Object?> get props => [];
}