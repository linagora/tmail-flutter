import '../../base/test_base.dart';
import '../../scenarios/mailbox/empty_and_recover_spam_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should empty and recover spam successfully',
    scenarioBuilder: ($) => EmptyAndRecoverSpamScenario($),
  );
} 