import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:server_settings/server_settings/tmail_server_settings_extension.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/ai_scribe_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/collapse_thread_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/label_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/spam_report_config.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/thread_detail_config.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum PreferencesOptionCategory { standard, experimental }

typedef _OptionStrings = ({
  String title,
  String explanation,
  String toggleDescription,
});

typedef PreferencesVisibilityContext = ({
  TMailServerSettingOptions? settingOption,
  PreferencesSetting localSettings,
  bool isExperimentalEnabled,
  bool isAIScribeAvailable,
  bool isAICapabilitySupported,
  bool isLabelVisibility,
});

enum PreferencesOptionType {
  readReceipt(isLocal: false),
  senderPriority(isLocal: false),
  thread(isLocal: true),
  collapseThread(
    isLocal: true,
    category: PreferencesOptionCategory.experimental,
  ),
  spamReport(isLocal: true),
  aiScribe(isLocal: true),
  aiNeedsAction(isLocal: false),
  label(isLocal: true);

  final bool isLocal;
  final PreferencesOptionCategory category;

  const PreferencesOptionType({
    required this.isLocal,
    this.category = PreferencesOptionCategory.standard,
  });

  bool get isExperimental => category == PreferencesOptionCategory.experimental;

  static final _parentTypes = <PreferencesOptionType, PreferencesOptionType>{
    PreferencesOptionType.collapseThread: PreferencesOptionType.thread,
  };

  PreferencesOptionType? get parentType => _parentTypes[this];

  bool get isChildOption => parentType != null;

  static final _stringBuilders =
      <PreferencesOptionType, _OptionStrings Function(AppLocalizations)>{
        readReceipt: (l) => (
          title: l.emailReadReceipts,
          explanation: l.emailReadReceiptsSettingExplanation,
          toggleDescription: l.emailReadReceiptsToggleDescription,
        ),
        senderPriority: (l) => (
          title: l.senderSetImportantFlag,
          explanation: l.senderImportantSettingExplanation,
          toggleDescription: l.senderImportantSettingToggleDescription,
        ),
        thread: (l) => (
          title: l.thread,
          explanation: l.threadSettingExplanation,
          toggleDescription: l.threadToggleDescription,
        ),
        collapseThread: (l) => (
          title: l.collapseThread,
          explanation: l.collapseThreadSettingExplanation,
          toggleDescription: l.collapseThreadToggleDescription,
        ),
        spamReport: (l) => (
          title: l.spamReports,
          explanation: l.spamReportsSettingExplanation,
          toggleDescription: l.spamReportToggleDescription,
        ),
        aiScribe: (l) => (
          title: l.aiScribe,
          explanation: l.aiScribeSettingExplanation,
          toggleDescription: l.aiScribeToggleDescription,
        ),
        aiNeedsAction: (l) => (
          title: l.aiNeedsAction,
          explanation: l.aiNeedsActionSettingExplanation,
          toggleDescription: l.aiNeedsActionToggleDescription,
        ),
        label: (l) => (
          title: l.labelVisibility,
          explanation: l.labelVisibilitySettingExplanation,
          toggleDescription: l.labelVisibilityToggleDescription,
        ),
      };

  // CHECKLIST: when adding a new PreferencesOptionType value, add an entry here.
  _OptionStrings _strings(AppLocalizations l) {
    final fn = _stringBuilders[this];
    if (fn == null) {
      throw StateError('PreferencesOptionType.$name missing from _stringBuilders');
    }
    return fn(l);
  }

  String getTitle(AppLocalizations l) => _strings(l).title;

  String getExplanation(AppLocalizations l) => _strings(l).explanation;

  String getToggleDescription(AppLocalizations l) => _strings(l).toggleDescription;

  // CHECKLIST: when adding a new PreferencesOptionType value, add an entry here.
  static final _enabledResolvers =
      <
        PreferencesOptionType,
        bool Function(TMailServerSettingOptions?, PreferencesSetting)
      >{
        readReceipt: (s, _) => s?.isAlwaysReadReceipts ?? false,
        senderPriority: (s, _) => s?.isDisplaySenderPriority ?? false,
        thread: (_, p) => p.threadConfig.isEnabled,
        collapseThread: (_, p) => p.collapseThreadConfig.isEnabled,
        spamReport: (_, p) => p.spamReportConfig.isEnabled,
        aiScribe: (_, p) => p.aiScribeConfig.isEnabled,
        aiNeedsAction: (s, _) => s?.isAINeedsActionEnabled ?? false,
        label: (_, p) => p.labelConfig.isEnabled,
      };

  // CHECKLIST: when adding a new PreferencesOptionType value, add an entry here.
  bool isEnabled(
    TMailServerSettingOptions? settingOption,
    PreferencesSetting preferencesSetting,
) {
    final fn = _enabledResolvers[this];
    if (fn == null) {
      throw StateError('PreferencesOptionType.$name missing from _enabledResolvers');
    }
    return fn(settingOption, preferencesSetting);
  }

  // Returns null for server-side options; they are handled via a separate path.
  static final _toggledConfigBuilders =
      <
        PreferencesOptionType,
        PreferencesConfig Function(PreferencesSetting, bool)
      >{
        thread: (s, e) => s.threadConfig.copyWith(isEnabled: !e),
        collapseThread: (s, e) =>
            s.collapseThreadConfig.copyWith(isEnabled: !e),
        spamReport: (s, e) => s.spamReportConfig.copyWith(isEnabled: !e),
        aiScribe: (s, e) => s.aiScribeConfig.copyWith(isEnabled: !e),
        label: (s, e) => s.labelConfig.copyWith(isEnabled: !e),
      };

  PreferencesConfig? createToggledConfig(
    PreferencesSetting currentSettings,
    bool currentIsEnabled,
  ) => _toggledConfigBuilders[this]?.call(currentSettings, currentIsEnabled);

  // CHECKLIST: when adding a new PreferencesOptionType value, add an entry here.
  static final _visibilityChecks =
      <PreferencesOptionType, bool Function(PreferencesVisibilityContext)>{
        readReceipt: (ctx) => ctx.settingOption != null,
        senderPriority: (ctx) => ctx.settingOption != null,
        thread: (ctx) => ctx.localSettings.configs.isNotEmpty,
        collapseThread: (ctx) =>
            ctx.isExperimentalEnabled &&
            ctx.localSettings.configs.isNotEmpty &&
            PreferencesOptionType.thread.isEnabled(
              ctx.settingOption,
              ctx.localSettings,
            ),
        spamReport: (ctx) => ctx.localSettings.configs.isNotEmpty,
        aiScribe: (ctx) =>
            ctx.localSettings.configs.isNotEmpty && ctx.isAIScribeAvailable,
        aiNeedsAction: (ctx) =>
            ctx.settingOption != null && ctx.isAICapabilitySupported,
        label: (ctx) => ctx.isLabelVisibility,
      };

  // CHECKLIST: when adding a new PreferencesOptionType value, add an entry here.
  bool isVisible(PreferencesVisibilityContext ctx) {
    final fn = _visibilityChecks[this];
    assert(fn != null, 'PreferencesOptionType.$name missing from _visibilityChecks');
    return fn!(ctx);
  }
}
