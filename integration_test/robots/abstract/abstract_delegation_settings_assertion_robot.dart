abstract class AbstractDelegationSettingsAssertionRobot {
  Future<void> expectDelegatedToMeListed(String ownerAddress);

  Future<void> expectNothingDelegatedToMe();

  Future<void> expectNoOneHasAccessToMyMailbox();

  Future<void> expectMyDelegatesListed(List<String> delegateAddresses);

  void expectNoTabFocusRing();
}
