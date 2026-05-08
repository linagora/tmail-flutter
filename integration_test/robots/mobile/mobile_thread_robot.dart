import '../abstract/abstract_thread_robot.dart';
import '../thread_robot.dart';
import 'package:patrol/patrol.dart';

class MobileThreadRobot extends ThreadRobot implements AbstractThreadRobot {
  MobileThreadRobot(PatrolIntegrationTester $) : super($);
  
  @override
  Future<void> expectAppGridVisible() async {
    await openMailbox();
    await $(#toggle_app_grid_button).waitUntilVisible();
  }

  @override
  Future<void> openAppGrid() async {
    await $(#toggle_app_grid_button).tap();
  }
}
