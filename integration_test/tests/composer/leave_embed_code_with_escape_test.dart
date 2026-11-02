import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/leave_embed_code_with_escape_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should not run event handlers typed in the Embed code view when leaving it with Escape',
    scenarioBuilder: ($, robots) => LeaveEmbedCodeWithEscapeScenario($, robots),
    tags: [TestTags.web],
  );
}
