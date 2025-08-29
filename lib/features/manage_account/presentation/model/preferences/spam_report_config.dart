import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/spam_report_state.dart';

part 'spam_report_config.g.dart';

@JsonSerializable()
class SpamReportConfig with EquatableMixin {
  final bool isEnabled;
  final int lastTimeDismissedMilliseconds;

  SpamReportConfig({
    this.isEnabled = true,
    this.lastTimeDismissedMilliseconds = 0,
  });

  factory SpamReportConfig.initial() {
    return SpamReportConfig(
      isEnabled: true,
      lastTimeDismissedMilliseconds: 0,
    );
  }

  factory SpamReportConfig.fromJson(Map<String, dynamic> json) =>
      _$SpamReportConfigFromJson(json);

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
