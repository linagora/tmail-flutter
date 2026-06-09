import 'package:tmail_ui_user/features/base/model/filter_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/empty_emails_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/abstract/abstract_advanced_search_robot.dart';
import '../../robots/abstract/abstract_search_robot.dart';
import '../../robots/abstract/abstract_thread_robot.dart';

class FilterDesyncSuggestionAdvancedSearchScenario extends BaseTestScenario {
  const FilterDesyncSuggestionAdvancedSearchScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const aliceEmail = 'alice@example.com';
    final appLocalizations = AppLocalizations();

    final AbstractThreadRobot threadRobot = robots.threadRobot();
    final AbstractSearchRobot searchRobot = robots.searchRobot();
    final AbstractAdvancedSearchRobot advancedSearchRobot = robots.advancedSearchRobot();

    await $(EmptyEmailsWidget).waitUntilVisible();

    // ── Pre-condition: both filters unselected ────────────────────────────
    await threadRobot.openSearchSuggestion();
    await searchRobot.expectSuggestionFilterSelected(QuickSearchFilter.hasAttachment, false);
    await searchRobot.expectSuggestionFilterSelected(QuickSearchFilter.fromMe, false);

    // Select hasAttachment in suggestion list
    await searchRobot.tapSuggestionFilter(QuickSearchFilter.hasAttachment);

    // Open advanced search: hasAttachment should be checked
    await searchRobot.openSearch();
    await advancedSearchRobot.expectHasAttachmentChecked(true);

    // Fill own email in From field
    await advancedSearchRobot.enterFromEmail(email);
    await advancedSearchRobot.expectFromFieldContains(email);

    // Close dialog: fromMe should now be selected in suggestion list
    await advancedSearchRobot.closeAdvancedSearch();
    await threadRobot.openSearchSuggestion();
    await searchRobot.expectSuggestionFilterSelected(QuickSearchFilter.hasAttachment, true);
    await searchRobot.expectSuggestionFilterSelected(QuickSearchFilter.fromMe, true);

    // Unselect hasAttachment via delete icon
    await searchRobot.deleteSuggestionFilter(QuickSearchFilter.hasAttachment);
    await searchRobot.expectSuggestionFilterSelected(QuickSearchFilter.hasAttachment, false);

    // Open advanced search: hasAttachment checkbox should be unchecked
    await searchRobot.openSearch();
    await advancedSearchRobot.expectHasAttachmentChecked(false);

    // Remove own email from From field
    await advancedSearchRobot.removeFromEmailTag(email);
    await advancedSearchRobot.expectFromFieldEmpty();

    // Close dialog: both filters should be unselected again
    await advancedSearchRobot.closeAdvancedSearch();
    await threadRobot.openSearchSuggestion();
    await searchRobot.expectSuggestionFilterSelected(QuickSearchFilter.hasAttachment, false);
    await searchRobot.expectSuggestionFilterSelected(QuickSearchFilter.fromMe, false);

    // ── Bug 1: fromMe ON with multiple from addresses ─────────────────────
    // Select fromMe in suggestion
    await searchRobot.tapSuggestionFilter(QuickSearchFilter.fromMe);

    // Open dialog: own email should appear in From field
    await searchRobot.openSearch();
    await advancedSearchRobot.expectFromFieldContains(email);

    // Add a second email address
    await advancedSearchRobot.enterFromEmail(aliceEmail);
    await advancedSearchRobot.expectFromFieldContains(aliceEmail);
    await advancedSearchRobot.expectFromFieldContains(email);

    // Close dialog: fromMe should remain selected (from contains own email)
    await advancedSearchRobot.closeAdvancedSearch();
    await threadRobot.openSearchSuggestion();
    await searchRobot.expectSuggestionFilterSelected(QuickSearchFilter.fromMe, true);

    // Reopen dialog: both addresses must still be present
    await searchRobot.openSearch();
    await advancedSearchRobot.focusField(FilterField.from);
    await advancedSearchRobot.expectFromFieldContains(email);
    await advancedSearchRobot.expectFromFieldContains(aliceEmail);
    await advancedSearchRobot.closeAdvancedSearch();
    await threadRobot.openSearchSuggestion();

    // ── Bug 2: quick filter change reflects in suggestion and dialog ───────
    // Select 7 days in suggestion (fromMe already active from Bug 1)
    await searchRobot.tapSuggestionFilter(QuickSearchFilter.last7Days);

    // Open dialog: receive time should show last7Days
    await searchRobot.openSearch();
    await advancedSearchRobot.expectReceiveTimeSelected(EmailReceiveTimeType.last7Days);

    // Tap Search button to start search with suggestion filters applied
    await advancedSearchRobot.tapSearchButton();

    // Quick filter dateTime chip should now reflect last7Days (selected)
    await searchRobot.expectQuickFilterDateTimeSelected(true);

    // Change to last30Days via quick filter popup
    await searchRobot.tapQuickFilterDateTimeChip();
    await searchRobot.selectQuickFilterDateTimeOption(appLocalizations.last30Days);

    // Open suggestion: 7 days must no longer be active
    await threadRobot.openSearchSuggestion();
    await searchRobot.expectSuggestionFilterSelected(QuickSearchFilter.last7Days, false);

    // Open dialog: receive time must not be last7Days
    await searchRobot.openSearch();
    await advancedSearchRobot.expectReceiveTimeSelected(EmailReceiveTimeType.last30Days);

    // ── Bug 3: all filters reset when leaving search mode ─────────────────
    // Close dialog, then tap inbox to exit search mode
    await advancedSearchRobot.closeAdvancedSearch();
    await threadRobot.selectMailboxByName('Inbox');

    // Open suggestion: fromMe and 7days must both be inactive
    await threadRobot.openSearchSuggestion();
    await searchRobot.expectSuggestionFilterSelected(QuickSearchFilter.fromMe, false);
    await searchRobot.expectSuggestionFilterSelected(QuickSearchFilter.last7Days, false);

    // Open dialog: from field empty, receive time = allTime
    await searchRobot.openSearch();
    await advancedSearchRobot.expectFromFieldEmpty();
    await advancedSearchRobot.expectReceiveTimeSelected(EmailReceiveTimeType.allTime);
    await advancedSearchRobot.closeAdvancedSearch();
  }
}
