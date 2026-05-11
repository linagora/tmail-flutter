import 'package:flutter/foundation.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';

import '../abstract/abstract_thread_robot.dart';
import '../thread_robot.dart';

class MobileThreadRobot extends ThreadRobot implements AbstractThreadRobot {
  MobileThreadRobot(PatrolIntegrationTester $) : super($);

  @override
  Future<void> expectAppGridVisible() async {
    await openMailbox();
    await $(const ValueKey(UiKeys.toggleAppGridButton)).waitUntilVisible();
  }

  @override
  Future<void> openAppGrid() async {
    await $(const ValueKey(UiKeys.toggleAppGridButton)).tap();
  }
}
