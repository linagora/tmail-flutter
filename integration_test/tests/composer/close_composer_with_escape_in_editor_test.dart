import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/close_composer_with_escape_in_editor_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should close the composer when pressing Escape in the editor body',
    scenarioBuilder: ($, robots) => CloseComposerWithEscapeInEditorScenario($, robots),
    tags: [TestTags.web],
  );
}
