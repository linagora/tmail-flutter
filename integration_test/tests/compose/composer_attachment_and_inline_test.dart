import '../../base/test_base.dart';
import '../../scenarios/composer/attachment_and_inline_image_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see attachment and inline image',
    scenarioBuilder: ($) => ComposerAttachmentAndInlineScenario($),
  );
}
