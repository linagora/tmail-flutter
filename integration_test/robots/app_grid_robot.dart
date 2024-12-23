
import 'package:flutter_test/flutter_test.dart';

import '../base/core_robot.dart';

class AppGridRobot extends CoreRobot {
  AppGridRobot(super.$);

  Future<void> openAppInAppGridByAppName(String appName) async {
    await $(find.text(appName)).tap();
  }
}