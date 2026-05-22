import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/ai_scribe_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/collapse_thread_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/label_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/spam_report_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/text_formatting_menu_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';

class PreferencesSetting with EquatableMixin {
  final List<PreferencesConfig> configs;

  PreferencesSetting(this.configs);

  factory PreferencesSetting.initial() {
    return PreferencesSetting([
      ThreadDetailConfig.initial(),
      CollapseThreadConfig.initial(),
      SpamReportConfig.initial(),
      TextFormattingMenuConfig.initial(),
      AIScribeConfig.initial(),
      LabelConfig.initial(),
    ]);
  }

  T getConfigOrDefault<T extends PreferencesConfig>(T defaultValue) =>
      configs.whereType<T>().firstOrNull ?? defaultValue;

  ThreadDetailConfig get threadConfig =>
      getConfigOrDefault(ThreadDetailConfig.initial());

  CollapseThreadConfig get collapseThreadConfig =>
      getConfigOrDefault(CollapseThreadConfig.initial());

  SpamReportConfig get spamReportConfig =>
      getConfigOrDefault(SpamReportConfig.initial());

  TextFormattingMenuConfig get textFormattingMenuConfig =>
      getConfigOrDefault(TextFormattingMenuConfig.initial());

  AIScribeConfig get aiScribeConfig =>
      getConfigOrDefault(AIScribeConfig.initial());

  LabelConfig get labelConfig =>
      getConfigOrDefault(LabelConfig.initial());

  bool get isCollapseThreadsEnabled =>
      threadConfig.isEnabled && collapseThreadConfig.isEnabled;

  @override
  List<Object?> get props => [configs];
}
