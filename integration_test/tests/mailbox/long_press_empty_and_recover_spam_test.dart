import '../../base/test_base.dart';
import '../../scenarios/mailbox/long_press_empty_and_recover_spam_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should empty and recover spam by long press mailbox successfully',
    scenarioBuilder: ($) => LongPressEmptyAndRecoverSpamScenario($),
  );
}