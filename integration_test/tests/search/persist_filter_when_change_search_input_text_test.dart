import '../../base/test_base.dart';
import '../../scenarios/search/persist_filter_when_change_search_input_text_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see the same email when selecting filter and changing search input text',
    scenarioBuilder: ($) => PersistFilterWhenChangeSearchInputTextScenario($),
  );
}
