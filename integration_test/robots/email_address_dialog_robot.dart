
import 'package:flutter_test/flutter_test.dart';

import '../base/core_robot.dart';

class EmailAddressDialogRobot extends CoreRobot {
  EmailAddressDialogRobot(super.$);

  Future<void> tapCloseDialogButton() async {
    await $(#email_address_dialog_close_button).tap();
  }
}