import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/switch_identity_discards_edited_signature_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should discard the edited signature when switching identity on web',
    scenarioBuilder: ($, robots) =>
        SwitchIdentityDiscardsEditedSignatureScenario($, robots),
    tags: [TestTags.web],
  );
}
