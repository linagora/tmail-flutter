import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../mobile/mobile_thread_robot.dart';

class WebThreadRobot extends MobileThreadRobot {
  WebThreadRobot(super.$);

  @override
  Future<void> expectAppGridVisible() async {
    await $(const ValueKey(UiKeys.toggleAppGridButton)).waitUntilVisible();
  }
}