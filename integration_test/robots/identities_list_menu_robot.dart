
import 'package:flutter_test/flutter_test.dart';

import '../base/core_robot.dart';

class IdentitiesListMenuRobot extends CoreRobot {
  IdentitiesListMenuRobot(super.$);

  Future<void> selectIdentityByName(String name) async {
    await $(find.text(name)).tap();
  }
}