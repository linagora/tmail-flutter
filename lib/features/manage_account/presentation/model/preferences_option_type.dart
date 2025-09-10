
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:server_settings/server_settings/tmail_server_settings_extension.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum PreferencesOptionType {
  readReceipt(isLocal: false),
  senderPriority(isLocal: false),
  thread(isLocal: true),
  spamReport(isLocal: true);

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
    }
  }
}