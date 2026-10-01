import '../../base/core_robot.dart';
import '../../utils/wait_for_condition.dart';

abstract class AbstractEmailRulesSettingRobot extends CoreRobot {
  AbstractEmailRulesSettingRobot(super.$);

  Future<void> expectRuleVisible(String ruleName);

  /// On desktop: taps the edit icon button directly.
  /// On mobile: taps the more button then selects [editRuleLabel] from bottom sheet.
  Future<void> tapEditRule(String ruleName, String editRuleLabel);

  /// Taps "Add a rule", or "Create my first rule" when the account has no rule.
  Future<void> openRuleCreator({
    required String addRuleLabel,
    required String createFirstRuleLabel,
  }) async {
    final addRuleButton = $(addRuleLabel);
    final createFirstRuleButton = $(createFirstRuleLabel);
    await waitForCondition(() async {
      await $.pump();
      return addRuleButton.exists || createFirstRuleButton.exists;
    });
    await (addRuleButton.exists ? addRuleButton : createFirstRuleButton).tap();
  }
}
