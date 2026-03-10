import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_scenario.dart';
import '../robots/language_robot.dart';
import '../robots/mailbox_menu_robot.dart';
import '../robots/setting_robot.dart';
import '../robots/thread_robot.dart';

mixin SettingScenarioMixin on BaseScenario {
  Future<void> goToSettingToChangeLanguage({
    required ThreadRobot threadRobot,
    required SettingRobot settingRobot,
    required MailboxMenuRobot mailboxMenuRobot,
    required LanguageRobot languageRobot,
    required AppLocalizations appLocalizations,
    required Locale locale,
  }) async {
    await threadRobot.openMailbox();
    await mailboxMenuRobot.openSetting();
    await _expectLanguageMenuItemVisible();

    await settingRobot.openLanguageMenuItem();
    await languageRobot.openLanguageContextMenu();
    await languageRobot.selectLanguage(locale, appLocalizations);
    await _expectLanguageViewByLocaleTitleVisible(appLocalizations);

    await settingRobot.backToSettingsFromFirstLevel();
    await settingRobot.closeSettings();
  }

  Future<void> _expectLanguageMenuItemVisible() async {
    await $(#setting_language_region).scrollTo(
      scrollDirection: AxisDirection.down,
    );
    await expectViewVisible($(#setting_language_region));
  }

  Future<void> _expectLanguageViewByLocaleTitleVisible(
    AppLocalizations appLocalizations,
  ) async {
    await expectViewVisible($(find.text(appLocalizations.language)));
  }
}
