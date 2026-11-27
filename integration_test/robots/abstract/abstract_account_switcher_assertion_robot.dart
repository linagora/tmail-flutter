abstract class AbstractAccountSwitcherAssertionRobot {
  Future<void> expectSwitcherInactive();

  Future<void> expectViewing(String ownerAddress);

  Future<void> expectMenuShowsDelegated(String ownerAddress);

  Future<void> expectSwitcherOnMine();

  /// The switcher's session no longer lists [ownerAddress].
  Future<void> expectNoLongerOffers(String ownerAddress);

  /// The switcher's session lists [ownerAddress].
  Future<void> expectOffers(String ownerAddress);

  Future<void> expectSwitchSettled(String ownerAddress);

  Future<void> expectShownIdentitiesInclude(String email);

  Future<void> expectUrlNamesShownAccount();

  Future<void> expectUrlNamesNoAccount();

  Future<void> expectUrlNamesOpenedFolder();

  Future<void> expectLoadingDialogVisible(String ownerAddress);

  Future<void> expectLoadingDialogGone();

  Future<void> expectCouldNotOpenToast(String ownerAddress);
}
