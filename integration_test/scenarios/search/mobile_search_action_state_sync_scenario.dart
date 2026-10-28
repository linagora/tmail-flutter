import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';

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
    await _waitForUnreadInboxCopy();

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

  // Search right after sending can hit only the Sent copy before delivery
  Future<void> _waitForUnreadInboxCopy() async {
    final dashboard = Get.find<MailboxDashBoardController>();
    final sinceLastRefresh = Stopwatch()..start();
    await waitForCondition(
      () async {
        await $.pump();
        if (dashboard.emailsInCurrentMailbox.any(
          (email) => email.subject == _subject && !email.hasRead,
        )) {
          return true;
        }
        if (sinceLastRefresh.elapsed >= const Duration(seconds: 5)) {
          sinceLastRefresh.reset();
          await Get.find<ThreadController>().refreshAllEmail();
        }
        return false;
      },
      timeout: TestTimeouts.long,
    );
  }
}
