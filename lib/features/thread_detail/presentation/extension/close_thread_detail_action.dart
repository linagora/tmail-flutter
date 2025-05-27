import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension CloseThreadDetailAction on ThreadDetailController {
  void closeThreadDetailAction(BuildContext? context) {
    if (isSearchRunning) {
      mailboxDashBoardController.dispatchRoute(DashboardRoutes.searchEmail);
    } else {
      mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
    }
    for (var emailId in emailIdsPresentation.keys) {
      mailboxDashBoardController
        ..dispatchEmailUIAction(CloseEmailInThreadDetailAction(emailId))
        ..dispatchEmailUIAction(EmailUIAction());
    }

    reset();
  }
}