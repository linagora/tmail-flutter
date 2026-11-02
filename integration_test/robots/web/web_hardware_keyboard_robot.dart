import 'package:patrol/patrol.dart';

import '../../base/core_robot.dart';
import '../abstract/abstract_hardware_keyboard_robot.dart';

class WebHardwareKeyboardRobot extends CoreRobot
    implements AbstractHardwareKeyboardRobot {
  WebHardwareKeyboardRobot(PatrolIntegrationTester $) : super($);

  @override
  Future<void> pressKey(String key) async {
    await $.platformAutomator.web.pressKey(key: key);
    await $.pumpAndTrySettle();
  }
}
