import '../../base/test_base.dart';
import '../../models/test_tags.dart';
import '../../scenarios/search/select_team_mailbox_folder_in_advanced_search_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should expand a team mailbox and pick one of its folders as the advanced search folder',
    scenarioBuilder: ($, robots) =>
        SelectTeamMailboxFolderInAdvancedSearchScenario($, robots),
    tags: [TestTags.web],
  );
}
