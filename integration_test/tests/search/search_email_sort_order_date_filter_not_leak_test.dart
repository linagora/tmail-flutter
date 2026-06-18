import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/search_email_sort_order_date_filter_not_leak_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should not leak date pagination cursor into JMAP filter when cycling sort orders (Most Recent → Oldest → Relevance)',
    scenarioBuilder: ($, robots) => SearchEmailSortOrderDateFilterNotLeakScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
