import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email_popup/presentation/email_popup_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/bindings/mailbox_dashboard_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

class EmailPopupBindings extends Bindings {
  @override
  void dependencies() {
    // Initialize dashboard controller and all its dependencies
    // (required by SingleEmailController for email operations)
    MailboxDashBoardBindings().dependencies();

    // Set popup mode immediately after dashboard controller is created
    final dashboardController = Get.find<MailboxDashBoardController>();
    dashboardController.isPopupMode.value = true;

    // Initialize popup controller
    Get.put(EmailPopupController());
  }
}
