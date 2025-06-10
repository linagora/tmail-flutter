
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:server_settings/server_settings/tmail_server_settings_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/local_settings_map_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum SettingOptionType {
  readReceipt,
  senderPriority,
  thread;

  String getTitle(AppLocalizations appLocalizations) {
    switch(this) {
      case SettingOptionType.readReceipt:
        return appLocalizations.emailReadReceipts;
      case SettingOptionType.senderPriority:
        return appLocalizations.senderSetImportantFlag;
      case SettingOptionType.thread:
        return appLocalizations.thread;
    }
  }

  String getExplanation(AppLocalizations appLocalizations) {
    switch(this) {
      case SettingOptionType.readReceipt:
        return appLocalizations.emailReadReceiptsSettingExplanation;
      case SettingOptionType.senderPriority:
        return appLocalizations.senderImportantSettingExplanation;
      case SettingOptionType.thread:
        return appLocalizations.threadSettingExplanation;
    }
  }

  String getToggleDescription(AppLocalizations appLocalizations) {
    switch(this) {
      case SettingOptionType.readReceipt:
        return appLocalizations.emailReadReceiptsToggleDescription;
      case SettingOptionType.senderPriority:
        return appLocalizations.senderImportantSettingToggleDescription;
      case SettingOptionType.thread:
        return appLocalizations.threadToggleDescription;
    }
  }

  bool isEnabled(
    TMailServerSettingOptions? settingOption,
    Map<SupportedLocalSetting, LocalSettingOptions?> localSettings,
  ) {
    switch(this) {
      case SettingOptionType.readReceipt:
        return settingOption?.isAlwaysReadReceipts ?? false;
      case SettingOptionType.senderPriority:
        return settingOption?.isDisplaySenderPriority ?? false;
      case SettingOptionType.thread:
        return localSettings.threadDetailEnabled ?? false;
    }
  }

  bool get isLocal {
    return switch (this) {
      thread => true,
      _ => false,
    };
  }
}