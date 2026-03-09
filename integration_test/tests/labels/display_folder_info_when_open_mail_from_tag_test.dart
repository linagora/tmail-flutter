import '../../base/test_base.dart';
import '../../scenarios/labels/display_folder_info_when_open_mail_from_tag_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should display folder info when open mail list from tag',
    scenarioBuilder: ($) => DisplayFolderInfoWhenOpenMailFromTagScenario($),
  );
}
