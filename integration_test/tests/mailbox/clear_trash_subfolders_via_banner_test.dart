import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/mailbox/clear_trash_subfolders_via_banner_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should delete trash subfolders when emptying trash via banner',
    tags: [TestTags.android, TestTags.ios, TestTags.web],
    scenarioBuilder: ($, robots) => ClearTrashSubfoldersViaBannerScenario($, robots),
  );
}
