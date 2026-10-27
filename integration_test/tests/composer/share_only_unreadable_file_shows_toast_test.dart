import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/composer/android/share_unreadable_file_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should show the error toast and not open composer when the only '
        'shared file is unreadable',
    tags: [TestTags.android],
    scenarioBuilder: ($, robots) => ShareUnreadableFileScenario($, robots),
  );
}
