import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/leave_embed_code_with_script_only_payload_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should not run a script typed alone in the Embed code view when leaving it with the Embed code button',
    scenarioBuilder: ($, robots) => LeaveEmbedCodeWithScriptOnlyPayloadScenario($, robots),
    tags: [TestTags.web],
  );
}
