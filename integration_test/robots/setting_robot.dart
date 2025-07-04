import 'package:flutter_test/flutter_test.dart';

import '../base/core_robot.dart';

class SettingRobot extends CoreRobot {
  SettingRobot(super.$);

  Future<void> openLanguageMenuItem() async {
    await $(#setting_language_region).tap();
  }
}