
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/abstract/abstract_search_robot.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';

/// Verifies that sort-order and date-filter changes clear load-more cursors.
///
/// Cases: allTime cursor leak, last7Days cursor restriction,
/// multi-sort cycle, and date-filter change clearing cursors.
class SearchEmailSortOrderDateFilterNotLeakScenario extends BaseTestScenario {
  const SearchEmailSortOrderDateFilterNotLeakScenario(super.$, super.robots);

  static const queryString = 'sort-order-date-filter-leak-test';
  static const listUsername = ['Alice', 'Brian', 'Charlotte'];

  @override
  Future<void> runTestLogic() async {
    final listProvisioningEmail = listUsername
      .map((username) => ProvisioningEmail(
        toEmail: '${username.toLowerCase()}@example.com',
        subject: queryString,
        content: '$queryString to $username',
      ))
      .toList();

    await robots.commonRobot().provisionEmail(listProvisioningEmail);
    await $.pumpAndSettle();

    final searchRobot = robots.searchRobot();
    await searchRobot.tapOnSearchField();
    await searchRobot.enterKeyword(queryString);
    await searchRobot.tapOnShowAllResultsText();
    await searchRobot.expectSearchResultEmailListVisible();

    final appLocalizations = AppLocalizations();
    final controller = Get.find<SearchEmailController>();
    final expectedCount = listProvisioningEmail.length;

    await _runCase1AllTime(searchRobot, appLocalizations, controller, expectedCount);
    await _runCase2Last7DaysOldest(searchRobot, appLocalizations, controller, expectedCount);
    await _runCase3Last7DaysMultiSortCycle(searchRobot, appLocalizations, controller, expectedCount);
    await _runCase4DateFilterChange(searchRobot, appLocalizations, controller, expectedCount);
  }

  /// Case 1: allTime — oldest load-more cursor must not leak to next sort.
  Future<void> _runCase1AllTime(
    AbstractSearchRobot searchRobot,
    AppLocalizations appLocalizations,
    SearchEmailController controller,
    int expectedCount,
  ) async {
    await _selectSortOrder(searchRobot, appLocalizations, controller, EmailSortOrderType.mostRecent);

    // Simulate auto-load-more setting a before cursor.
    controller.updateSimpleSearchFilter(
      beforeOption: Some(UTCDate(DateTime.now().subtract(const Duration(days: 30)))),
    );

    await _selectSortOrder(searchRobot, appLocalizations, controller, EmailSortOrderType.oldest);
    expect(controller.searchEmailFilter.value.before, isNull,
      reason: 'before must be cleared when switching sort order');

    // Simulate auto-load-more setting a startDate cursor.
    controller.updateSimpleSearchFilter(
      startDateOption: Some(UTCDate(DateTime.now().subtract(const Duration(days: 30)))),
    );

    await _selectSortOrder(searchRobot, appLocalizations, controller, EmailSortOrderType.relevance);
    _assertCursorsCleared(controller, 'allTime');
    expect(
      controller.searchEmailFilter.value.emailReceiveTimeType,
      equals(EmailReceiveTimeType.allTime),
    );
    await searchRobot.expectEmailListCountAtLeast(expectedCount);
  }

  /// Case 2: last7Days — oldest auto-load-more cursor must not restrict date range.
  Future<void> _runCase2Last7DaysOldest(
    AbstractSearchRobot searchRobot,
    AppLocalizations appLocalizations,
    SearchEmailController controller,
    int expectedCount,
  ) async {
    await _selectDateFilter(searchRobot, appLocalizations, controller, EmailReceiveTimeType.last7Days);
    await _selectSortOrder(searchRobot, appLocalizations, controller, EmailSortOrderType.oldest);

    // Simulate auto-load-more (large-screen auto-fill).
    controller.updateSimpleSearchFilter(
      startDateOption: Some(UTCDate(DateTime.now().subtract(const Duration(days: 5)))),
    );

    await _selectSortOrder(searchRobot, appLocalizations, controller, EmailSortOrderType.relevance);
    _assertCursorsCleared(controller, 'last7Days');
    await searchRobot.expectEmailListCountAtLeast(expectedCount);
  }

  /// Case 3: last7Days multi-sort cycle — each transition clears the cursor.
  ///
  /// Sequence: oldest → load-more → mostRecent → load-more → oldest → load-more → relevance.
  Future<void> _runCase3Last7DaysMultiSortCycle(
    AbstractSearchRobot searchRobot,
    AppLocalizations appLocalizations,
    SearchEmailController controller,
    int expectedCount,
  ) async {
    await _selectSortOrder(searchRobot, appLocalizations, controller, EmailSortOrderType.oldest);
    controller.updateSimpleSearchFilter(
      startDateOption: Some(UTCDate(DateTime.now().subtract(const Duration(days: 6)))),
    );

    await _selectSortOrder(searchRobot, appLocalizations, controller, EmailSortOrderType.mostRecent);
    expect(controller.searchEmailFilter.value.startDate, isNull,
      reason: 'startDate must be cleared on transition oldest → mostRecent');

    controller.updateSimpleSearchFilter(
      beforeOption: Some(UTCDate(DateTime.now().subtract(const Duration(days: 3)))),
    );

    await _selectSortOrder(searchRobot, appLocalizations, controller, EmailSortOrderType.oldest);
    expect(controller.searchEmailFilter.value.before, isNull,
      reason: 'before must be cleared on transition mostRecent → oldest');

    controller.updateSimpleSearchFilter(
      startDateOption: Some(UTCDate(DateTime.now().subtract(const Duration(days: 4)))),
    );

    await _selectSortOrder(searchRobot, appLocalizations, controller, EmailSortOrderType.relevance);
    _assertCursorsCleared(controller, 'last7Days multi-sort cycle');
    await searchRobot.expectEmailListCountAtLeast(expectedCount);
  }

  /// Case 4: date filter change clears cursor; subsequent sort changes also work.
  ///
  /// Sequence: last7Days + oldest → load-more → change to last30Days → oldest → load-more → relevance.
  Future<void> _runCase4DateFilterChange(
    AbstractSearchRobot searchRobot,
    AppLocalizations appLocalizations,
    SearchEmailController controller,
    int expectedCount,
  ) async {
    await _selectSortOrder(searchRobot, appLocalizations, controller, EmailSortOrderType.oldest);
    controller.updateSimpleSearchFilter(
      startDateOption: Some(UTCDate(DateTime.now().subtract(const Duration(days: 6)))),
    );

    await _selectDateFilter(searchRobot, appLocalizations, controller, EmailReceiveTimeType.last30Days);
    expect(controller.searchEmailFilter.value.startDate, isNull,
      reason: 'startDate must be cleared when date filter changes');

    await _selectSortOrder(searchRobot, appLocalizations, controller, EmailSortOrderType.oldest);
    controller.updateSimpleSearchFilter(
      startDateOption: Some(UTCDate(DateTime.now().subtract(const Duration(days: 20)))),
    );

    await _selectSortOrder(searchRobot, appLocalizations, controller, EmailSortOrderType.relevance);
    _assertCursorsCleared(controller, 'after date filter change to last30Days');
    // Provisioned emails are recent, so they fall within last30Days.
    await searchRobot.expectEmailListCountAtLeast(expectedCount);
  }

  Future<void> _selectSortOrder(
    AbstractSearchRobot searchRobot,
    AppLocalizations appLocalizations,
    SearchEmailController controller,
    EmailSortOrderType sortOrder,
  ) async {
    await searchRobot.scrollToEndListSearchFilter();
    await searchRobot.openSortOrderMenu();
    await searchRobot.expectSortOrderMenuVisible();
    await searchRobot.selectSortOrder(
      sortOrder.getTitleByAppLocalizations(appLocalizations),
    );
    // Wait for the controller to reflect the new sort order before asserting results.
    await waitForCondition(
      () async {
        await $.pump();
        return controller.searchEmailFilter.value.sortOrderType == sortOrder;
      },
      timeout: TestTimeouts.short,
    );
    await searchRobot.expectSearchResultEmailListVisible();
  }

  Future<void> _selectDateFilter(
    AbstractSearchRobot searchRobot,
    AppLocalizations appLocalizations,
    SearchEmailController controller,
    EmailReceiveTimeType receiveTimeType,
  ) async {
    await searchRobot.scrollToDateTimeButtonFilter();
    await searchRobot.openDateTimeBottomDialog();
    await searchRobot.expectDateTimeFilterContextMenuVisible();
    await searchRobot.selectDateTime(
      receiveTimeType.getTitleByAppLocalizations(appLocalizations),
    );
    // Wait for the controller to reflect the new date filter before asserting results.
    await waitForCondition(
      () async {
        await $.pump();
        return controller.emailReceiveTimeType.value == receiveTimeType;
      },
      timeout: TestTimeouts.short,
    );
    await searchRobot.expectSearchResultEmailListVisible();
  }

  void _assertCursorsCleared(SearchEmailController controller, String context) {
    expect(
      controller.searchEmailFilter.value.startDate,
      isNull,
      reason: 'startDate must be cleared: $context',
    );
    expect(
      controller.searchEmailFilter.value.before,
      isNull,
      reason: 'before must be cleared: $context',
    );
    expect(
      controller.searchEmailFilter.value.endDate,
      isNull,
      reason: 'endDate must be cleared: $context',
    );
  }
}
