import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/close_composer_with_escape_in_subject_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should close the composer when pressing Escape in the subject field',
    scenarioBuilder: ($, robots) => CloseComposerWithEscapeInSubjectScenario($, robots),
    tags: [TestTags.web],
  );
}
