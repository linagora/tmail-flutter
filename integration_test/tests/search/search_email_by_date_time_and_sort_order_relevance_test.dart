import '../../base/test_base.dart';
import '../../scenarios/search_email_by_date_time_and_sort_order_relevance_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see list email displayed by date time `Last 7 days` and sort order `Relevance` when search email successfully',
    scenarioBuilder: ($) => SearchEmailByDatetimeAndSortOrderRelevanceScenario($),
  );
}