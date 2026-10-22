import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/composer_body_os_keys_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Composer body inserts OS key events after subject was focused',
    scenarioBuilder: ($, robots) => ComposerBodyOsKeysScenario($, robots),
    tags: [TestTags.android],
  );
}
