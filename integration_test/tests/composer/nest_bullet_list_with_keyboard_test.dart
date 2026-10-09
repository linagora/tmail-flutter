import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/nest_bullet_list_with_keyboard_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should nest a list item under the one above when pressing Tab, and move an empty nested item up when pressing Enter, in the composer editor',
    scenarioBuilder: ($, robots) => NestBulletListWithKeyboardScenario($, robots),
    tags: [TestTags.web],
  );
}
