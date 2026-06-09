import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/advanced_filter_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/providers/search_view_open_provider.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension AdvancedSearchOpenSyncExtension on AdvancedFilterController {
  ProviderSubscription<AsyncValue<bool>> createSearchViewOpenSyncWorker(
    ProviderContainer container,
  ) {
    return container.listen<AsyncValue<bool>>(
      searchViewOpenProvider,
      (prev, next) {
        next.whenData((isOpen) {
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
      },
      fireImmediately: false,
    );
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
    // Persist from addresses directly — bypasses updateFilterEmail's side-effect of
    // calling clearSuggestionFilterState(fromMe), which would undo the loop above.
    searchController.searchEmailFilter.value = searchController.searchEmailFilter.value.copyWith(
      fromOption: Some(dialogFilter.from),
    );
    searchController.searchEmailFilter.refresh();
  }
}
