abstract class AbstractWorkplaceAccountSwitcherAssertionRobot {
  Future<void> expectChipHidden();

  Future<void> expectViewing(String ownerAddress);

  Future<void> expectMenuShowsDelegated(String ownerAddress);

  Future<void> expectSwitchSettled(String ownerAddress);

  Future<void> expectSwitcherOnMine();
}
