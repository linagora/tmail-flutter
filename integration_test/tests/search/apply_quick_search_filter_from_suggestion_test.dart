import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/apply_quick_search_filter_from_suggestion_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should apply the attachment filter immediately when a suggestion chip is selected before submitting',
    scenarioBuilder: ($, robots) =>
        ApplyQuickSearchFilterFromSuggestionScenario($, robots),
    tags: [TestTags.web],
  );
}
