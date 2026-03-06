import 'package:flutter_test/flutter_test.dart';

import '../../base/core_robot.dart';

class AddLabelModalRobot extends CoreRobot {
  AddLabelModalRobot(super.$);

  Future<void> tapCreateANewLabel() async {
    await $(#create_a_new_label_button).tap();
  }
}
