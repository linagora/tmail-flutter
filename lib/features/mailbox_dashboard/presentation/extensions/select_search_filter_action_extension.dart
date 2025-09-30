import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

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
}
