/// What the mailbox offers for the shown account: my own account or a delegated one.
abstract class AbstractShownAccountOffersAssertionRobot {
  Future<void> expectMyVacationBannerShown();

  Future<void> expectMyVacationBannerHidden();

  Future<void> expectRecoverDeletedMessagesOffered();

  Future<void> expectRecoverDeletedMessagesNotOffered();

  Future<void> expectRecipientMenuWithoutCreateRule();
}
