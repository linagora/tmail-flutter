import '../../base/test_base.dart';
import '../../scenarios/mailbox/pull_to_refresh_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should refresh email list when pull to refresh',
    scenarioBuilder: ($) => PullToRefreshScenario($),
  );
}