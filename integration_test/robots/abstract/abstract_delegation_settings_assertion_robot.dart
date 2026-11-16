abstract class AbstractDelegationSettingsAssertionRobot {
  Future<void> expectDelegatedToMeListed(String ownerAddress);

  Future<void> expectNothingDelegatedToMe();
}
