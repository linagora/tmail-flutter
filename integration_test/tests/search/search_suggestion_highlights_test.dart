import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search_suggestion_highlights_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see highlighted keyword in search suggestion',
    scenarioBuilder: ($, robots) => SearchSuggestionHighlightsScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
