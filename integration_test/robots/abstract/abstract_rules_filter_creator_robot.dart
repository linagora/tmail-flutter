import '../../base/core_robot.dart';

abstract class AbstractRulesFilterCreatorRobot extends CoreRobot {
  AbstractRulesFilterCreatorRobot(super.$);

  Future<void> expectCreatorViewVisible();

  Future<void> enterRuleName(String name);

  Future<void> selectEmptyActionSlot(String actionName, String selectActionHint);

  Future<void> tapAddActionButton();

  Future<void> tapCreateRuleButton();

  Future<void> expectWarningTextVisible(String warningText);

  Future<void> confirmWarningDialog(String confirmLabel);

  Future<void> expectCreatorViewClosed();
}
