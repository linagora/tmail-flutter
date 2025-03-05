
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:server_settings/server_settings/tmail_server_settings_extension.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum SettingOptionType {
  readReceipt,
  senderPriority;

  String getTitle(AppLocalizations appLocalizations) {
    switch(this) {
      case SettingOptionType.readReceipt:
        return appLocalizations.emailReadReceipts;
      case SettingOptionType.senderPriority:
        return appLocalizations.senderSetImportantFlag;
    }
  }

  String getExplanation(AppLocalizations appLocalizations) {
    switch(this) {
      case SettingOptionType.readReceipt:
        return appLocalizations.emailReadReceiptsSettingExplanation;
      case SettingOptionType.senderPriority:
        return appLocalizations.senderImportantSettingExplanation;
    }
  }

  String getToggleDescription(AppLocalizations appLocalizations) {
    switch(this) {
      case SettingOptionType.readReceipt:
        return appLocalizations.emailReadReceiptsToggleDescription;
      case SettingOptionType.senderPriority:
        return appLocalizations.senderImportantSettingToggleDescription;
    }
  }

  bool isEnabled(TMailServerSettingOptions settingOption) {
    switch(this) {
      case SettingOptionType.readReceipt:
        return settingOption.isAlwaysReadReceipts;
      case SettingOptionType.senderPriority:
        return settingOption.isDisplaySenderPriority;
    }
  }
}