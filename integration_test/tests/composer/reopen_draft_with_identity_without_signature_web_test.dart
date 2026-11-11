import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/reopen_draft_with_identity_without_signature_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should not ask to save when closing an unmodified reopened draft that has an identity without signature on web',
    scenarioBuilder: ($, robots) =>
        ReopenDraftWithIdentityWithoutSignatureScenario($, robots),
    tags: [TestTags.web],
  );
}
