import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/ai_scribe_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/label_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/quoted_content_config.dart';
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
      AIScribeConfig.initial(),
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

  AIScribeConfig get aiScribeConfig {
    final aiConfig =
        configs.firstWhereOrNull((config) => config is AIScribeConfig);
    if (aiConfig != null) {
      return aiConfig as AIScribeConfig;
    } else {
      return AIScribeConfig.initial();
    }
  }

  LabelConfig get labelConfig {
    final labelConfig =
        configs.firstWhereOrNull((config) => config is LabelConfig);
    if (labelConfig != null) {
      return labelConfig as LabelConfig;
    } else {
      return LabelConfig.initial();
    }
  }

  QuotedContentConfig get quotedContentConfig {
    final quotedConfig =
        configs.firstWhereOrNull((config) => config is QuotedContentConfig);
    if (quotedConfig != null) {
      return quotedConfig as QuotedContentConfig;
    } else {
      return QuotedContentConfig.initial();
    }
  }

  @override
  List<Object?> get props => [configs];
}
