import '../../base/test_base.dart';
import '../../scenarios/search_suggestion_highlights_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see highlighted keyword in search suggestion',
    scenarioBuilder: ($) => SearchSuggestionHighlightsScenario($),
  );
}