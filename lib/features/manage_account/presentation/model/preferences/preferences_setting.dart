import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences/spam_report_config.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences/thread_detail_config.dart';

part 'preferences_setting.g.dart';

@JsonSerializable(explicitToJson: true)
class PreferencesSetting with EquatableMixin {
  final ThreadDetailConfig threadDetail;
  final SpamReportConfig spamReport;

  PreferencesSetting({
    required this.threadDetail,
    required this.spamReport,
  });

  factory PreferencesSetting.initial() {
    return PreferencesSetting(
      threadDetail: ThreadDetailConfig.initial(),
      spamReport: SpamReportConfig.initial(),
    );
  }

  factory PreferencesSetting.fromJson(Map<String, dynamic> json) =>
      _$PreferencesSettingFromJson(json);

  Map<String, dynamic> toJson() => _$PreferencesSettingToJson(this);

  @override
  List<Object?> get props => [threadDetail, spamReport];
}

extension PreferencesSettingExtension on PreferencesSetting {
  PreferencesSetting copyWith({
    ThreadDetailConfig? threadDetail,
    SpamReportConfig? spamReport,
  }) {
    return PreferencesSetting(
      threadDetail: threadDetail ?? this.threadDetail,
      spamReport: spamReport ?? this.spamReport,
    );
  }

  PreferencesSetting updateThreadDetail(bool enabled) {
    return copyWith(threadDetail: threadDetail.copyWith(isEnabled: enabled));
  }

  PreferencesSetting updateSpamReport({
    bool? isEnabled,
    int? lastTimeDismissedMilliseconds,
  }) {
    return copyWith(
      spamReport: spamReport.copyWith(
        isEnabled: isEnabled ?? spamReport.isEnabled,
        lastTimeDismissedMilliseconds: lastTimeDismissedMilliseconds ??
            spamReport.lastTimeDismissedMilliseconds,
      ),
    );
  }
}
