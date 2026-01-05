import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:labels/model/label.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';

extension SelectSearchFilterActionExtension on MailboxDashBoardController {
  void selectStarredSearchFilter() {
    final listHasKeywordFiltered = searchController.listHasKeywordFiltered;
    listHasKeywordFiltered.add(KeyWordIdentifier.emailFlagged.value);
    searchController.updateFilterEmail(
      hasKeywordOption: Some(listHasKeywordFiltered),
    );
    dispatchAction(StartSearchEmailAction());
  }

  void selectUnreadSearchFilter() {
    searchController.updateFilterEmail(unreadOption: const Some(true));
    dispatchAction(StartSearchEmailAction());
  }

  void deleteStarredSearchFilter() {
    final listHasKeywordFiltered = searchController.listHasKeywordFiltered;
    listHasKeywordFiltered.remove(KeyWordIdentifier.emailFlagged.value);
    searchController.updateFilterEmail(
      hasKeywordOption: Some(listHasKeywordFiltered),
    );
    dispatchAction(StartSearchEmailAction());
  }

  void deleteUnreadSearchFilter() {
    searchController.updateFilterEmail(unreadOption: const None());
    dispatchAction(StartSearchEmailAction());
  }

  void deleteQuickSearchFilter({required QuickSearchFilter filter}) {
    switch (filter) {
      case QuickSearchFilter.labels:
        searchController.updateFilterEmail(labelOption: const None());
        break;
      default:
        break;
    }
    dispatchAction(StartSearchEmailAction());
  }

  void onSelectLabelFilter(Label? newLabel) {
    searchController.updateFilterEmail(labelOption: optionOf(newLabel));
    dispatchAction(StartSearchEmailAction());
  }
}
