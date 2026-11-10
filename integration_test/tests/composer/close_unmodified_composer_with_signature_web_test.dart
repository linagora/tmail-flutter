import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/close_unmodified_composer_with_signature_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should close an unmodified composer with a signature without asking to save on web',
    scenarioBuilder: ($, robots) => CloseUnmodifiedComposerWithSignatureScenario($, robots),
    tags: [TestTags.web],
  );
}
