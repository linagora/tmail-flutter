
import 'package:flutter/cupertino.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SendingQueueController extends BaseController {

  final dashboardController = getBinding<MailboxDashBoardController>();

  final listSendingEmailController = ScrollController();

  void openMailboxMenu() {
    dashboardController!.openMailboxMenuDrawer();
  }

  @override
  void onClose() {
    listSendingEmailController.dispose();
    super.onClose();
  }
}