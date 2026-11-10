abstract class AbstractAccountSwitcherAssertionRobot {
  Future<void> expectSwitcherInactive();

  Future<void> expectViewing(String ownerAddress);

  Future<void> expectMenuShowsDelegated(String ownerAddress);

  Future<void> expectSwitcherOnMine();

  Future<void> expectSwitchSettled(String ownerAddress);

  Future<void> expectLoadingDialogVisible(String ownerAddress);

  Future<void> expectLoadingDialogGone();

  Future<void> expectCouldNotOpenToast(String ownerAddress);
}
