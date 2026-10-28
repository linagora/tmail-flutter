import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/restore_minimized_composer_after_embed_code_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should not run event handlers typed in the Embed code view when the minimized composer is shown again',
    scenarioBuilder: ($, robots) => RestoreMinimizedComposerAfterEmbedCodeScenario($, robots),
    tags: [TestTags.web],
  );
}
