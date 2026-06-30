
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_store_email_sort_order_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';

/// Verifies that a sort order persisted to storage is reloaded and applied to
/// a search started from the inline search bar.
///
/// This exercises in-process persistence (store → clear → load) rather than a
/// real app relaunch, which is not available in this integration test harness.
class SortOrderPersistedFromSearchBarScenario extends BaseTestScenario {
  const SortOrderPersistedFromSearchBarScenario(super.$, super.robots);

  static const queryString = 'sort order persisted';
  static const listUsername = ['Alice', 'Brian', 'Charlotte', 'David', 'Emma'];

  @override
  Future<void> runTestLogic() async {
    await robots.commonRobot().provisionEmail(
      listUsername
          .map((name) => ProvisioningEmail(
                toEmail: '${name.toLowerCase()}@example.com',
                subject: queryString,
                content: '$queryString for user $name',
              ))
          .toList(),
    );
    await $.pumpAndSettle();

    final dashboardController = Get.find<MailboxDashBoardController>();

    // Persist 'oldest' sort order as the user's stored preference
    dashboardController.storeEmailSortOrder(EmailSortOrderType.oldest);

    // Reset to default so the next call reproduces a clean initial state
    dashboardController.searchController.clearSearchFilter(
      sortOrderType: SearchEmailFilter.defaultSortOrder,
    );

    // Reload from storage, retrying until the async persistence write has
    // completed and propagated into searchController.searchEmailFilter.
    // Polling the round-trip avoids a flaky fixed wall-clock wait.
    await waitForCondition(
      () async {
        dashboardController.loadStoredEmailSortOrder();
        await $.pump();
        return dashboardController.searchController.sortOrderFiltered ==
            EmailSortOrderType.oldest;
      },
      timeout: TestTimeouts.medium,
    );

    final searchRobot = robots.searchRobot();
    await searchRobot.tapOnSearchField();
    await searchRobot.enterKeyword(queryString);
    await searchRobot.tapOnShowAllResultsText();

    await searchRobot.expectSearchResultEmailListVisible();
    // Provisioned emails persist on the mail server and accumulate across runs,
    // so assert "at least" the count we just provisioned (this also polls until
    // the JMAP results render) rather than an exact, re-run-sensitive count.
    await searchRobot.expectEmailListCountAtLeast(listUsername.length);
    await searchRobot.expectEmailListSortedByOldest();
  }
}
