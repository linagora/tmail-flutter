import 'package:flutter/material.dart';

import '../abstract/abstract_settings_robot.dart';
import '../setting_robot.dart';

class MobileSettingsRobot extends SettingRobot
    implements AbstractSettingsRobot {
  MobileSettingsRobot(super.$);

  @override
  Future<void> togglePreference(String title) async {
    await $(ValueKey(title)).tap();
  }

  @override
  Future<void> expectPreference(
    String title, {
    required bool switchedOn,
  }) async {
    final key = switchedOn
        ? 'setting_option_switch_on'
        : 'setting_option_switch_off';
    await $(ValueKey(title)).$(ValueKey(key)).waitUntilVisible();
  }
}
