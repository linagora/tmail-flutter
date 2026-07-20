import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_store_email_sort_order_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/quick_search_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/notifier/quick_search_filter_action_notifier.dart';

extension SelectSearchFilterActionExtension on MailboxDashBoardController {
  void onDeleteSearchFilterAction(
    QuickSearchFilterActionNotifier searchFilterActionNotifier,
    QuickSearchFilter searchFilter,
  ) {
    final applied =
        searchFilterActionNotifier.deleteQuickSearchFilter(searchFilter);
    if (!applied) return;

    if (searchFilter == QuickSearchFilter.dateTime) {
      dispatchAction(SelectDateRangeToAdvancedSearch(
        receiveTime: EmailReceiveTimeType.allTime,
      ));
    } else if (searchFilter == QuickSearchFilter.sortBy) {
      storeEmailSortOrder(SearchEmailFilter.defaultSortOrder);
    }
  }
}
