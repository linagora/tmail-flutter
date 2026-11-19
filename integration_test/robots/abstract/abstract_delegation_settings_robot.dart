import 'abstract_delegation_settings_assertion_robot.dart';

abstract class AbstractDelegationSettingsRobot {
  AbstractDelegationSettingsAssertionRobot get assertion;

  Future<void> tapRemoveAccess(String ownerAddress);

  Future<void> confirmRemoveAccess();
}
