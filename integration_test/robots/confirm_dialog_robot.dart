import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter_test/flutter_test.dart';

import '../base/core_robot.dart';

class ConfirmDialogRobot extends CoreRobot {
  ConfirmDialogRobot(super.$);

  Future<void> selectActionByName(String name) async {
    await $(ConfirmDialogButton).$(name).tap();
  }
}
