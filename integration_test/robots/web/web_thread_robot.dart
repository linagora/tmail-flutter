import '../mobile/mobile_thread_robot.dart';

class WebThreadRobot extends MobileThreadRobot {
  WebThreadRobot(super.$);

  @override
  Future<void> expectAppGridVisible() async {
    await $(#toggle_app_grid_button).waitUntilVisible();
  }
}