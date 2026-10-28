import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/leave_embed_code_with_button_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should not run event handlers typed in the Embed code view when leaving it with the Embed code button',
    scenarioBuilder: ($, robots) => LeaveEmbedCodeWithButtonScenario($, robots),
    tags: [TestTags.web],
  );
}
