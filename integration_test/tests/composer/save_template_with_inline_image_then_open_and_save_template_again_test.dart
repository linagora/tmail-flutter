import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/save_template_with_inline_image_then_open_and_save_template_again_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should save template successfully a second time '
        'after reopening a template email that contains an inline image',
    scenarioBuilder: ($, robots) =>
        SaveTemplateWithInlineImageThenOpenAndSaveTemplateAgainScenario($, robots),
    tags: [TestTags.android, TestTags.ios, TestTags.web],
  );
}
