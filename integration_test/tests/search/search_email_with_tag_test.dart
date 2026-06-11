import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/search_email_with_tag_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should display email list correctly when search with tag',
    scenarioBuilder: ($, robots) => SearchEmailWithTagScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
