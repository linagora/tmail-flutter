import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/save_draft_with_attachment_then_open_and_save_draft_again_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should save draft successfully a second time '
        'after reopening a draft email that contains an attachment',
    scenarioBuilder: ($, robots) =>
        SaveDraftWithAttachmentThenOpenAndSaveDraftAgainScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
