import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/search_by_label_while_inbox_refresh_in_flight_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should list the label search result when an inbox refresh finishes while the search is loading',
    tags: [TestTags.web],
    scenarioBuilder: ($, robots) =>
        SearchByLabelWhileInboxRefreshInFlightScenario($, robots),
  );
}
