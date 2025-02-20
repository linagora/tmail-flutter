import '../../base/test_base.dart';
import '../../scenarios/search_email_with_sort_order_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see list email displayed by sort order selected when search email successfully',
    scenarioBuilder: ($) => SearchEmailWithSortOrderScenario($),
  );
}