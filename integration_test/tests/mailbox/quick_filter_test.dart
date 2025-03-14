import '../../base/test_base.dart';
import '../../scenarios/mailbox/quick_filter_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see email with expected condition '
      'when quick filter email changed',
    scenarioBuilder: ($) => QuickFilterScenario($),
  );
}