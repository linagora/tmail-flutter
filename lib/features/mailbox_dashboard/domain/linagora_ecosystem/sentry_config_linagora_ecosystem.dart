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

  /// Starting position of the per-user reporting toggle, not a master switch:
  /// on-prem serves `false` so nothing is sent until a user opts in.
  /// Falls back to [enabled] so deployments without this key are unaffected.
  @JsonKey(fromJson: _parseBool)
  final bool? userOptInByDefault;

  SentryConfigLinagoraEcosystem({
    this.enabled,
    this.dsn,
    this.environment,
    this.userOptInByDefault,
  });

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

  bool get isUserOptedInByDefault => userOptInByDefault ?? enabled ?? false;

  @override
  List<Object?> get props => [enabled, dsn, environment, userOptInByDefault];
}

extension SentryConfigLinagoraEcosystemExtension on SentryConfigLinagoraEcosystem {
  Future<SentryConfig> toSentryConfig({
    bool isReportingAllowed = false,
  }) async {
    const dartDefineRelease = String.fromEnvironment('SENTRY_RELEASE');
    final release = dartDefineRelease.isNotEmpty
        ? dartDefineRelease
        : await ApplicationManager().getAppVersion();

    return SentryConfig(
      dsn: dsn ?? '',
      environment: environment ?? '',
      release: release,
      isAvailable: enabled ?? false,
      isReportingAllowed: isReportingAllowed,
    );
  }
}
