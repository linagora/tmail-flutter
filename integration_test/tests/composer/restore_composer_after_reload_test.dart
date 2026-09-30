import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/restore_composer_after_reload_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should restore subject, recipient and body after beforeunload '
        'and remove the snapshot on normal close',
    scenarioBuilder: ($, robots) =>
        RestoreComposerAfterReloadScenario($, robots),
    tags: [TestTags.web],
  );
}
