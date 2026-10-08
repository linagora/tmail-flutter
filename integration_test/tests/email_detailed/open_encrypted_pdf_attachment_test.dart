import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/email_detailed/open_encrypted_pdf_attachment_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should open a password-protected PDF attachment after a wrong then the right password',
    scenarioBuilder: ($, robots) => OpenEncryptedPdfAttachmentScenario($, robots),
    tags: [TestTags.web],
  );
}
