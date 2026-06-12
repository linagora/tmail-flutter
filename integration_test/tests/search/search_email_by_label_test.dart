import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/search_email_by_label_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should display emails and empty view correctly when searching by label',
    tags: [TestTags.android, TestTags.ios, TestTags.web],
    scenarioBuilder: ($, robots) => SearchEmailByLabelScenario($, robots),
  );
}
