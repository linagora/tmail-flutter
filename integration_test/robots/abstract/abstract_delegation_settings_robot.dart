import 'abstract_add_delegates_robot.dart';
import 'abstract_delegation_settings_assertion_robot.dart';

abstract class AbstractDelegationSettingsRobot {
  AbstractDelegationSettingsAssertionRobot get assertion;

  AbstractAddDelegatesRobot get addDelegates;

  Future<void> openDelegatedToMeTab();

  Future<void> tapRemoveAccess(String ownerAddress);

  Future<void> confirmRemoveAccess();

  Future<void> confirmRemoveDelegate();
}
