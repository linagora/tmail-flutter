import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/edit_as_new_drops_relative_href_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should drop relative links from the sender content in Edit as new on web',
    scenarioBuilder: ($, robots) => EditAsNewDropsRelativeHrefScenario($, robots),
    tags: [TestTags.web],
  );
}
