import '../../base/test_base.dart';
import '../../scenarios/mailbox/create_rename_move_and_delete_mailbox_scenario.dart';

void main() {
  TestBase().runPatrolTest(
    description: 'Should create, rename, move and delete mailbox successfully',
    scenarioBuilder: ($) => CreateRenameMoveAndDeleteMailboxScenario($),
  );
}