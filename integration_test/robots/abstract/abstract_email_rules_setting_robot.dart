import '../../base/core_robot.dart';

abstract class AbstractEmailRulesSettingRobot extends CoreRobot {
  AbstractEmailRulesSettingRobot(super.$);

  Future<void> expectRuleVisible(String ruleName);

  /// On desktop: taps the edit icon button directly.
  /// On mobile: taps the more button then selects [editRuleLabel] from bottom sheet.
  Future<void> tapEditRule(String ruleName, String editRuleLabel);
}
