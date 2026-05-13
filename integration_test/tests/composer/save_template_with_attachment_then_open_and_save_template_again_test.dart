import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/save_template_with_attachment_then_open_and_save_template_again_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should save template successfully a second time '
        'after reopening a template email that contains an attachment',
    scenarioBuilder: ($, robots) =>
        SaveTemplateWithAttachmentThenOpenAndSaveTemplateAgainScenario($, robots),
    tags: [TestTags.android, TestTags.ios],
  );
}
