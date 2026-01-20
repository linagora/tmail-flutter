
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:server_settings/server_settings/tmail_server_settings_extension.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum PreferencesOptionType {
  readReceipt(isLocal: false),
  senderPriority(isLocal: false),
  thread(isLocal: true),
  spamReport(isLocal: true),
  aiScribe(isLocal: true),
  aiNeedsAction(isLocal: false),
  label(isLocal: true),
  quotedContent(isLocal: true),
  openEmailInNewWindow(isLocal: true);

  final bool isLocal;

  const PreferencesOptionType({required this.isLocal});

  String getTitle(AppLocalizations appLocalizations) {
    switch(this) {
      case PreferencesOptionType.readReceipt:
        return appLocalizations.emailReadReceipts;
      case PreferencesOptionType.senderPriority:
        return appLocalizations.senderSetImportantFlag;
      case PreferencesOptionType.thread:
        return appLocalizations.thread;
      case PreferencesOptionType.spamReport:
        return appLocalizations.spamReports;
      case PreferencesOptionType.aiScribe:
        return appLocalizations.aiScribe;
      case PreferencesOptionType.aiNeedsAction:
        return appLocalizations.aiNeedsAction;
      case PreferencesOptionType.label:
        return appLocalizations.labelVisibility;
      case PreferencesOptionType.quotedContent:
        return appLocalizations.quotedContentVisibility;
      case PreferencesOptionType.openEmailInNewWindow:
        return appLocalizations.openEmailInNewWindow;
    }
  }

  String getExplanation(AppLocalizations appLocalizations) {
    switch(this) {
      case PreferencesOptionType.readReceipt:
        return appLocalizations.emailReadReceiptsSettingExplanation;
      case PreferencesOptionType.senderPriority:
        return appLocalizations.senderImportantSettingExplanation;
      case PreferencesOptionType.thread:
        return appLocalizations.threadSettingExplanation;
      case PreferencesOptionType.spamReport:
        return appLocalizations.spamReportsSettingExplanation;
      case PreferencesOptionType.aiScribe:
        return appLocalizations.aiScribeSettingExplanation;
      case PreferencesOptionType.aiNeedsAction:
        return appLocalizations.aiNeedsActionSettingExplanation;
      case PreferencesOptionType.label:
        return appLocalizations.labelVisibilitySettingExplanation;
      case PreferencesOptionType.quotedContent:
        return appLocalizations.quotedContentSettingExplanation;
      case PreferencesOptionType.openEmailInNewWindow:
        return appLocalizations.openEmailInNewWindowSettingExplanation;
    }
  }

  String getToggleDescription(AppLocalizations appLocalizations) {
    switch(this) {
      case PreferencesOptionType.readReceipt:
        return appLocalizations.emailReadReceiptsToggleDescription;
      case PreferencesOptionType.senderPriority:
        return appLocalizations.senderImportantSettingToggleDescription;
      case PreferencesOptionType.thread:
        return appLocalizations.threadToggleDescription;
      case PreferencesOptionType.spamReport:
        return appLocalizations.spamReportToggleDescription;
      case PreferencesOptionType.aiScribe:
        return appLocalizations.aiScribeToggleDescription;
      case PreferencesOptionType.aiNeedsAction:
        return appLocalizations.aiNeedsActionToggleDescription;
      case PreferencesOptionType.label:
        return appLocalizations.labelVisibilityToggleDescription;
      case PreferencesOptionType.quotedContent:
        return appLocalizations.quotedContentToggleDescription;
      case PreferencesOptionType.openEmailInNewWindow:
        return appLocalizations.openEmailInNewWindowToggleDescription;
    }
  }

  bool isEnabled(
    TMailServerSettingOptions? settingOption,
    PreferencesSetting preferencesSetting,
  ) {
    switch(this) {
      case PreferencesOptionType.readReceipt:
        return settingOption?.isAlwaysReadReceipts ?? false;
      case PreferencesOptionType.senderPriority:
        return settingOption?.isDisplaySenderPriority ?? false;
      case PreferencesOptionType.thread:
        return preferencesSetting.threadConfig.isEnabled;
      case PreferencesOptionType.spamReport:
        return preferencesSetting.spamReportConfig.isEnabled;
      case PreferencesOptionType.aiScribe:
        return preferencesSetting.aiScribeConfig.isEnabled;
      case PreferencesOptionType.aiNeedsAction:
        return settingOption?.isAINeedsActionEnabled ?? false;
      case PreferencesOptionType.label:
        return preferencesSetting.labelConfig.isEnabled;
      case PreferencesOptionType.quotedContent:
        return preferencesSetting.quotedContentConfig.isHiddenByDefault;
      case PreferencesOptionType.openEmailInNewWindow:
        return preferencesSetting.openEmailInNewWindowConfig.isEnabled;
    }
  }
}