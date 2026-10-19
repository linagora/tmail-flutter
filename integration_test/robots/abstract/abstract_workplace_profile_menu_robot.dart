import 'abstract_workplace_profile_menu_assertion_robot.dart';

abstract class AbstractWorkplaceProfileMenuRobot {
  AbstractWorkplaceProfileMenuAssertionRobot get assertion;

  Future<void> openProfileMenu();
}
