import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';

class SettingRobot extends CoreRobot {
  SettingRobot(super.$);

  Future<void> openLanguageMenuItem() async {
    await $(#setting_language_region).tap();
  }

  Future<void> openPreferencesMenuItem() async {
    await $(#setting_preferences).tap();
  }

  Future<void> openProfilesMenuItem() async {
    await $(#setting_profiles).tap();
  }

  Future<void> switchOnThreadSetting() async {
    final threadSettingOn = $(ValueKey(AppLocalizations().thread))
        .$(#setting_option_switch_on)
        .visible;
    if (!threadSettingOn) {
      await $(ValueKey(AppLocalizations().thread)).tap();
    }
  }

  Future<void> backToSettingsFromFirstLevel() async {
    await $(#settings_first_level_close_button).tap();
  }

  Future<void> closeSettings() async {
    await $(#settings_close_button).tap();
  }
}