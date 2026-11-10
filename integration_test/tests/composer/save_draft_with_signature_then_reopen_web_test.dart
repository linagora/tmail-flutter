import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/save_draft_with_signature_then_reopen_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should show the identity signature once and not ask to save when reopening a draft on web',
    scenarioBuilder: ($, robots) =>
        SaveDraftWithSignatureThenReopenScenario($, robots),
    tags: [TestTags.web],
  );
}
