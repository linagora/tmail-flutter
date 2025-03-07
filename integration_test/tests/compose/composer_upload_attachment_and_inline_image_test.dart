import '../../base/test_base.dart';
import '../../scenarios/composer/upload_attachment_and_inline_image_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should see attachment and inline image '
      'when upload success in composer',
    scenarioBuilder: ($) => ComposerUploadAttachmentAndInlineImageScenario($),
  );
}
