import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';

class MobileSearchActionStateSyncScenario extends BaseTestScenario {
  const MobileSearchActionStateSyncScenario(super.$, super.robots);

  static const _subject = 'Mobile Search action state sync';
  static const _searchKeyword = 'action state sync';

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    final commonRobot = robots.commonRobot();
    final searchRobot = robots.searchRobot();

    await commonRobot.waitForMailboxReady();
    await commonRobot.provisionEmail([
      ProvisioningEmail(
        toEmail: email,
        subject: _subject,
        content: _subject,
      ),
    ], requestReadReceipt: false);

    await searchRobot.viewport.resizeToMobileViewport();
    await searchRobot.tapOnSearchField();
    await searchRobot.enterKeyword(_searchKeyword);
    await searchRobot.tapOnShowAllResultsText();
    await searchRobot.expectEmailWithSubjectVisible(_subject);
    await searchRobot.assertion.expectEmailWithSubjectMarkedUnread(_subject);

    await searchRobot.action.selectUnreadEmailWithSubject(_subject);
    await searchRobot.action.markSelectedEmailsAsRead();
    await searchRobot.assertion.expectEmailWithSubjectMarkedRead(_subject);

    await searchRobot.viewport.resizeToTabletViewport();
    await searchRobot.action.selectEmailWithSubject(_subject);
    await searchRobot.action.archiveSelectedEmails();
    await searchRobot.assertion.expectEmailWithSubjectInArchive(_subject);
  }
}
