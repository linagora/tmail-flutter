import 'package:flutter_test/flutter_test.dart';

import '../base/core_robot.dart';

class EmailRobot extends CoreRobot {
  EmailRobot(super.$);

  Future<void> onTapForwardEmail() async {
    await $(#forward_email_button).tap();
    await $.pump(const Duration(seconds: 2));
  }
}