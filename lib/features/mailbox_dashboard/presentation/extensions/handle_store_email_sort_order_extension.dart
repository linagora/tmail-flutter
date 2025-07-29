
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';

extension HandleStoreEmailSortOrderExtension on MailboxDashBoardController {
  void storeEmailSortOrder(EmailSortOrderType emailSortOrder) {
    setUpDefaultEmailSortOrder(emailSortOrder);
    consumeState(storeEmailSortOrderInteractor.execute(emailSortOrder));
  }

  void loadStoredEmailSortOrder() {
    consumeState(getStoredEmailSortOrderInteractor.execute());
  }

  void setUpDefaultEmailSortOrder(EmailSortOrderType storedSortOrder) {
    log('$runtimeType::setUpDefaultEmailSortOrder: $storedSortOrder');
    currentSortOrder = storedSortOrder;
    dispatchAction(SynchronizeEmailSortOrderAction(currentSortOrder));
  }
}