import '../../base/test_base.dart';
import '../../scenarios/search/search_email_with_sort_order_relevance_by_default_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see list email displayed by sort order `Relevance` by default when search email successfully',
    scenarioBuilder: ($) => SearchEmailWithSortOrderRelevanceByDefaultScenario($),
  );
}