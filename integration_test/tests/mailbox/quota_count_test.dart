import '../../base/test_base.dart';
import '../../scenarios/mailbox/quota_count_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see quota increase when send email successfully',
    scenarioBuilder: ($) => QuotaCountScenario($),
  );
}