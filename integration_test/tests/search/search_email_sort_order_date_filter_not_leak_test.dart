import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/search_email_sort_order_date_filter_not_leak_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should not leak pagination cursors when changing sort order or date filter',
    scenarioBuilder: ($, robots) => SearchEmailSortOrderDateFilterNotLeakScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
