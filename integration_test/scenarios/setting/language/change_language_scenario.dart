import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../../base/base_test_scenario.dart';
import '../../../robots/language_robot.dart';
import '../../../robots/mailbox_menu_robot.dart';
import '../../../robots/setting_robot.dart';
import '../../../robots/thread_robot.dart';

class ChangeLanguageScenario extends BaseTestScenario {
  const ChangeLanguageScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final settingRobot = SettingRobot($);
    final languageRobot = LanguageRobot($);
    final appLocalizations = AppLocalizations();

    await threadRobot.openMailbox();
    await _expectUserAvatarVisible();

    await mailboxMenuRobot.openSetting();
    await _expectSettingViewVisible(appLocalizations);
    await $.pumpAndSettle(duration: seconds(1));

    await _expectLanguageMenuItemVisible();
    await settingRobot.openLanguageMenuItem();
    await $.pumpAndSettle(duration: seconds(1));
    await _expectLanguageViewWithEnglishTitleVisible();

    await languageRobot.openLanguageContextMenu();
    await _expectLanguageContextMenuVisible();

    await languageRobot.selectLanguage(const Locale('vi'), appLocalizations);
    await $.pumpAndSettle(duration: seconds(3));
    await _expectLanguageViewWithVietnameseTitleVisible();
  }

  Future<void> _expectUserAvatarVisible() => expectViewVisible($(#user_avatar));

  Future<void> _expectSettingViewVisible(AppLocalizations appLocalizations) =>
      expectViewVisible($(find.text(appLocalizations.settings)));

  Future<void> _expectLanguageMenuItemVisible() async {
    await $(#setting_language_region).scrollTo(
      scrollDirection: AxisDirection.down,
    );
    await expectViewVisible($(#setting_language_region));
  }

  Future<void> _expectLanguageViewWithEnglishTitleVisible() =>
      expectViewVisible($(find.text('Language')));

  Future<void> _expectLanguageContextMenuVisible() async {
    await expectViewVisible($(#language_context_menu));
  }

  Future<void> _expectLanguageViewWithVietnameseTitleVisible() =>
      expectViewVisible($(find.text('Ngôn ngữ')));
}
