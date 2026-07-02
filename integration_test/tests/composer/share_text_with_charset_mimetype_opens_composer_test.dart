import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/android/share_text_from_external_opens_composer_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should open composer with shared text when an external app shares '
        'text with a charset-suffixed plain-text mimeType',
    tags: [TestTags.android],
    scenarioBuilder: ($, robots) => ShareTextFromExternalOpensComposerScenario(
      $,
      robots,
      sharedText: 'Shared plain text from an external app',
      mimeType: 'text/plain;charset=utf-8',
    ),
  );
}
