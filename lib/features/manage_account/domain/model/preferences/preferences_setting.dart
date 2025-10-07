import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
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
      SpamReportConfig.initial(),
      TextFormattingMenuConfig.initial(),
    ]);
  }

  ThreadDetailConfig get threadConfig {
    final threadConfig =
        configs.firstWhereOrNull((config) => config is ThreadDetailConfig);
    if (threadConfig != null) {
      return threadConfig as ThreadDetailConfig;
    } else {
      return ThreadDetailConfig.initial();
    }
  }

  SpamReportConfig get spamReportConfig {
    final spamConfig =
        configs.firstWhereOrNull((config) => config is SpamReportConfig);
    if (spamConfig != null) {
      return spamConfig as SpamReportConfig;
    } else {
      return SpamReportConfig.initial();
    }
  }

  TextFormattingMenuConfig get textFormattingMenuConfig {
    final formatConfig = configs
        .firstWhereOrNull((config) => config is TextFormattingMenuConfig);
    if (formatConfig != null) {
      return formatConfig as TextFormattingMenuConfig;
    } else {
      return TextFormattingMenuConfig.initial();
    }
  }

  @override
  List<Object?> get props => [configs];
}
