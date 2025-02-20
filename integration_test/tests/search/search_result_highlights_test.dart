import '../../base/test_base.dart';
import '../../scenarios/search_result_highlights_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see highlighted keyword in search result',
    scenarioBuilder: ($) => SearchResultHighlightsScenario($),
  );
}