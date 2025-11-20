import '../../base/test_base.dart';
import '../../scenarios/mailbox/display_empty_view_for_favorite_folder_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should display empty view when no mail favorites',
    scenarioBuilder: ($) => DisplayEmptyViewForFavoriteFolderScenario($),
  );
}
