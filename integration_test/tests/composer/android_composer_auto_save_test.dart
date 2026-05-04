import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/android/android_composer_background_restore_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should keep composer open after app is sent to background (RC1)',
    scenarioBuilder: ($, robots) =>
        AndroidComposerBackgroundRestoreScenario($, robots),
    tags: [TestTags.android],
  );
}
