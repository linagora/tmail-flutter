import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search_email_with_sort_order_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see list email displayed by sort order selected when search email successfully',
    tags: [TestTags.android, TestTags.ios, TestTags.web],
    scenarioBuilder: ($, robots) => SearchEmailWithSortOrderScenario($, robots),
  );
}
