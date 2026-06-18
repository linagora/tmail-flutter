
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

/// Regression test for the sort-order date-filter leak bug.
///
/// Bug: after cycling sort orders Most Recent → Oldest → Relevance,
/// the `startDate` pagination cursor set during Oldest load-more was not
/// cleared when switching back to Relevance, causing a spurious `after`
/// field in the JMAP request.
///
/// Fix: `_searchEmailAction` in SearchEmailController now always clears
/// `before` and clears `startDate` unless emailReceiveTimeType is customRange.
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

    // Select Most Recent to enter date-cursor pagination mode.
    await searchRobot.scrollToEndListSearchFilter();
    await searchRobot.openSortOrderMenu();
    await searchRobot.expectSortOrderMenuVisible();
    await searchRobot.selectSortOrder(
      EmailSortOrderType.mostRecent.getTitleByAppLocalizations(appLocalizations),
    );
    await searchRobot.expectSearchResultEmailListVisible();

    // Simulate a load-more having occurred while Most Recent was active.
    // In production this sets `before` = receivedAt of the last fetched email.
    final controller = Get.find<SearchEmailController>();
    final fakeBeforeDate = UTCDate(DateTime.now().subtract(const Duration(days: 30)));
    controller.updateSimpleSearchFilter(
      beforeOption: Some(fakeBeforeDate),
    );
    await $.pumpAndSettle();

    // Switch to Oldest — this triggers _searchEmailAction which should clear `before`.
    await searchRobot.scrollToEndListSearchFilter();
    await searchRobot.openSortOrderMenu();
    await searchRobot.expectSortOrderMenuVisible();
    await searchRobot.selectSortOrder(
      EmailSortOrderType.oldest.getTitleByAppLocalizations(appLocalizations),
    );
    await searchRobot.expectSearchResultEmailListVisible();

    // Assert `before` was cleared when switching to Oldest.
    expect(controller.searchEmailFilter.value.before, isNull,
      reason: 'before must be cleared when switching sort order');

    // Simulate a load-more having occurred while Oldest was active.
    // In production this sets `startDate` = receivedAt of the last fetched email.
    final fakeStartDate = UTCDate(DateTime.now().subtract(const Duration(days: 30)));
    controller.updateSimpleSearchFilter(
      startDateOption: Some(fakeStartDate),
    );
    await $.pumpAndSettle();

    // Switch back to Relevance — THIS IS THE KEY ACTION.
    // The fix ensures startDate is cleared when emailReceiveTimeType != customRange.
    await searchRobot.scrollToEndListSearchFilter();
    await searchRobot.openSortOrderMenu();
    await searchRobot.expectSortOrderMenuVisible();
    await searchRobot.selectSortOrder(
      EmailSortOrderType.relevance.getTitleByAppLocalizations(appLocalizations),
    );
    await searchRobot.expectSearchResultEmailListVisible();

    // Assert: pagination cursors were cleared (the core invariant of the fix).
    expect(
      controller.searchEmailFilter.value.startDate,
      isNull,
      reason: 'startDate pagination cursor must be cleared when switching to Relevance',
    );
    expect(
      controller.searchEmailFilter.value.before,
      isNull,
      reason: 'before pagination cursor must be cleared when switching sort order',
    );

    // Assert: emailReceiveTimeType was allTime, so the leaked startDate would have
    // injected a spurious `after` field into the JMAP filter.
    expect(
      controller.searchEmailFilter.value.emailReceiveTimeType,
      equals(EmailReceiveTimeType.allTime),
    );

    // Assert: all provisioned emails are still visible (no spurious date filter).
    await searchRobot.expectEmailListCount(listProvisioningEmail.length);
  }
}
