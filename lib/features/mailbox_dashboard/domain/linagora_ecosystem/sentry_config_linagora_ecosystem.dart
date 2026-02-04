import 'package:core/utils/application_manager.dart';
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/empty_linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_properties.dart';

part 'sentry_config_linagora_ecosystem.g.dart';

@JsonSerializable(explicitToJson: true, includeIfNull: false)
class SentryConfigLinagoraEcosystem extends LinagoraEcosystemProperties {
  @JsonKey(fromJson: _parseBool)
  final bool? enabled;
  final String? dsn;
  final String? environment;

  SentryConfigLinagoraEcosystem({this.enabled, this.dsn, this.environment});

  factory SentryConfigLinagoraEcosystem.fromJson(Map<String, dynamic> json) =>
      _$SentryConfigLinagoraEcosystemFromJson(json);

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return null;
  }

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

extension SentryConfigLinagoraEcosystemExtension on SentryConfigLinagoraEcosystem {
  Future<SentryConfig> toSentryConfig() async {
    final appVersion = await ApplicationManager().getAppVersion();

    return SentryConfig(
      dsn: dsn ?? '',
      environment: environment ?? '',
      release: appVersion,
      isAvailable: enabled ?? false,
    );
  }
}