import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/upload_attachment_as_blob_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should upload a web attachment as its blob with the full byte count',
    scenarioBuilder: ($, robots) => UploadAttachmentAsBlobScenario($, robots),
    tags: [TestTags.web],
  );
}
