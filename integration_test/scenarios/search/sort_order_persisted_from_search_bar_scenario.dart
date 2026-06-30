
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_store_email_sort_order_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';

class SortOrderPersistedFromSearchBarOnRestartScenario extends BaseTestScenario {
  const SortOrderPersistedFromSearchBarOnRestartScenario(super.$, super.robots);

  static const queryString = 'sort order restart';
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
    await $.pump(const Duration(seconds: 1));

    // Reset to default so the next call reproduces a clean cold-restart state
    dashboardController.searchController.clearSearchFilter(
      sortOrderType: SearchEmailFilter.defaultSortOrder,
    );

    // Simulate app restart: load the stored sort order and wait for it to
    // propagate into searchController.searchEmailFilter
    dashboardController.loadStoredEmailSortOrder();
    await waitForCondition(
      () async =>
          dashboardController.searchController.sortOrderFiltered ==
          EmailSortOrderType.oldest,
      timeout: TestTimeouts.medium,
    );
    await $.pump(const Duration(seconds: 1));

    final searchRobot = robots.searchRobot();
    await searchRobot.tapOnSearchField();
    await searchRobot.enterKeyword(queryString);
    await searchRobot.tapOnShowAllResultsText();

    await searchRobot.expectSearchResultEmailListVisible();
    await searchRobot.expectEmailListCount(listUsername.length);
    await searchRobot.expectEmailListSortedByOldest();
  }
}
