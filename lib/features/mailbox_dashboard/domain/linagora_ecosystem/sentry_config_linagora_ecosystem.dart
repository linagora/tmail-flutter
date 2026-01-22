import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/empty_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_properties.dart';

part 'sentry_config_linagora_ecosystem.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SentryConfigLinagoraEcosystem extends LinagoraEcosystemProperties {
  final bool? enabled;
  final String? dsn;
  final String? environment;

  SentryConfigLinagoraEcosystem({this.enabled, this.dsn, this.environment});

  factory SentryConfigLinagoraEcosystem.fromJson(Map<String, dynamic> json) =>
      _$SentryConfigLinagoraEcosystemFromJson(json);

  Map<String, dynamic> toJson() => _$SentryConfigLinagoraEcosystemToJson(this);

  static LinagoraEcosystemProperties? deserialize(dynamic json) {
    if (json is Map<String, dynamic>) {
      return SentryConfigLinagoraEcosystem.fromJson(json);
    } else {
      return EmptyLinagoraEcosystem();
    }
  }

  @override
  List<Object?> get props => [enabled, dsn, environment];
}
