import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:server_settings/server_settings/tmail_server_settings_extension.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef _OptionStrings = ({
  String title,
  String explanation,
  String toggleDescription,
});

enum PreferencesOptionType {
  readReceipt(isLocal: false),
  senderPriority(isLocal: false),
  thread(isLocal: true),
  spamReport(isLocal: true),
  aiScribe(isLocal: true),
  aiLabelCategorization(isLocal: false),
  label(isLocal: true);

  final bool isLocal;

  const PreferencesOptionType({required this.isLocal});

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
        aiLabelCategorization: (l) => (
          title: l.aiLabelCategorization,
          explanation: l.aiLabelCategorizationSettingExplanation,
          toggleDescription: l.aiLabelCategorizationToggleDescription,
        ),
        label: (l) => (
          title: l.labelVisibility,
          explanation: l.labelVisibilitySettingExplanation,
          toggleDescription: l.labelVisibilityToggleDescription,
        ),
      };

  static List<PreferencesOptionType> get missingFromStringBuilders =>
      values.where((e) => !_stringBuilders.containsKey(e)).toList();

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

  static List<PreferencesOptionType> get missingFromEnabledResolvers =>
      values.where((e) => !_enabledResolvers.containsKey(e)).toList();

  // CHECKLIST: when adding a new PreferencesOptionType value, add an entry here.
  static final _enabledResolvers =
      <
        PreferencesOptionType,
        bool Function(TMailServerSettingOptions?, PreferencesSetting)
      >{
        readReceipt: (s, _) => s?.isAlwaysReadReceipts ?? false,
        senderPriority: (s, _) => s?.isDisplaySenderPriority ?? false,
        thread: (_, p) => p.threadConfig.isEnabled,
        spamReport: (_, p) => p.spamReportConfig.isEnabled,
        aiScribe: (_, p) => p.aiScribeConfig.isEnabled,
        aiLabelCategorization: (s, _) => s?.isAILabelCategorizationEnabled ?? false,
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
}
