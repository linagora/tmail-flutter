import '../../base/test_base.dart';
import '../../scenarios/labels/create_a_new_tag_from_an_email_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description:
        'Should create a new label and add to email when select "Create a new Label" button in add label modal of detailed email view',
    scenarioBuilder: ($) => CreateANewTagFromAnEmailScenario($),
  );
}
