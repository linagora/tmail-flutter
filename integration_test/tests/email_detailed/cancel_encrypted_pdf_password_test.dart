import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/email_detailed/cancel_encrypted_pdf_password_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should explain that the PDF attachment is password-protected when the password prompt is cancelled',
    scenarioBuilder: ($, robots) => CancelEncryptedPdfPasswordScenario($, robots),
    tags: [TestTags.web],
  );
}
