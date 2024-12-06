
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_properties.dart';

part 'default_linagora_ecosystem.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class DefaultLinagoraEcosystem extends LinagoraEcosystemProperties with EquatableMixin {
  final dynamic properties;

  DefaultLinagoraEcosystem(this.properties);

  factory DefaultLinagoraEcosystem.fromJson(Map<String, dynamic> json) => _$DefaultLinagoraEcosystemFromJson(json);

  Map<String, dynamic> toJson() => _$DefaultLinagoraEcosystemToJson(this);
  
  @override
  List<Object?> get props => [properties];
}