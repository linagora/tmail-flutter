import 'package:flutter/foundation.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_preferences_robot.dart';

abstract class PreferencesRobot extends CoreRobot implements AbstractPreferencesRobot {
  PreferencesRobot(super.$);
  
  @override
  Future<void> togglePreferenceOption(String title) async {
    await $(ValueKey(title)).tap();
  }

  @override
  Future<void> expectPreferenceOption(
    String title, {
    required bool switchedOn,
  }) async {
    final key = switchedOn
        ? 'setting_option_switch_on'
        : 'setting_option_switch_off';
    await $(ValueKey(title)).$(ValueKey(key)).waitUntilVisible();
  }
}