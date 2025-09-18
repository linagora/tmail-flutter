import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';

part 'spam_report_config.g.dart';

@JsonSerializable()
class SpamReportConfig extends PreferencesConfig {
  final bool isEnabled;
  final int lastTimeDismissedMilliseconds;

  SpamReportConfig({
    this.isEnabled = true,
    this.lastTimeDismissedMilliseconds = 0,
  });

  factory SpamReportConfig.initial() => SpamReportConfig();

  factory SpamReportConfig.fromJson(Map<String, dynamic> json) =>
      _$SpamReportConfigFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$SpamReportConfigToJson(this);

  @override
  List<Object> get props => [isEnabled, lastTimeDismissedMilliseconds];
}

extension SpamReportConfigExtension on SpamReportConfig {
  SpamReportConfig copyWith({
    bool? isEnabled,
    int? lastTimeDismissedMilliseconds,
  }) {
    return SpamReportConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      lastTimeDismissedMilliseconds:
          lastTimeDismissedMilliseconds ?? this.lastTimeDismissedMilliseconds,
    );
  }

  SpamReportState get spamReportState =>
      isEnabled ? SpamReportState.enabled : SpamReportState.disabled;
}
