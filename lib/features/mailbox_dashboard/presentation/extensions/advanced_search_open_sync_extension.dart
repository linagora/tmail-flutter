import 'package:dartz/dartz.dart';
import 'package:get/get_rx/src/rx_workers/rx_workers.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension AdvancedSearchOpenSyncExtension on AdvancedFilterController {
  Worker createSearchViewOpenSyncWorker() {
    return ever(searchController.isAdvancedSearchViewOpen, (bool isOpen) {
      if (isOpen) {
        final hasSuggestionOverrides =
            searchController.listFilterOnSuggestionForm.isNotEmpty ||
            searchController.removedSuggestionFilters.isNotEmpty;
        if (!hasSuggestionOverrides) return;
        initSearchFilterField(
          currentContext,
          filterOverride: searchController.mergeWithSuggestionFilters(
            mailboxDashBoardController.ownEmailAddress.value,
          ),
        );
      } else {
        _syncSuggestionFiltersOnDialogClose();
      }
    });
  }

  void _syncSuggestionFiltersOnDialogClose() {
    final context = currentContext;
    if (context == null) return;
    final dialogFilter = memorySearchFilter;
    final userEmail = mailboxDashBoardController.ownEmailAddress.value;
    for (final filter in QuickSearchFilter.suggestionPopupFilters) {
      final isActiveInDialog = filter.isSelected(
        context,
        dialogFilter,
        searchController.sortOrderFiltered,
        userEmail,
      );
      if (isActiveInDialog) {
        searchController.addQuickSearchFilterToSuggestionSearchView(filter);
      } else if (searchController.listFilterOnSuggestionForm.contains(filter)) {
        searchController.deleteQuickSearchFilterFromSuggestionSearchView(filter);
        searchController.syncFromSuggestionPostSearch(filter);
      }
    }
    // Persist the from field so manually added addresses survive a close-without-apply.
    searchController.updateFilterEmail(fromOption: Some(dialogFilter.from));
  }
}
