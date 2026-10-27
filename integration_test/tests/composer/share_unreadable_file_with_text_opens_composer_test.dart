import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/android/share_unreadable_file_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should show the error toast and open composer with the shared text '
        'when a share has an unreadable file next to a text',
    tags: [TestTags.android],
    scenarioBuilder: ($, robots) => ShareUnreadableFileScenario(
      $,
      robots,
      sharedText: 'Shared text next to an unreadable file',
    ),
  );
}
