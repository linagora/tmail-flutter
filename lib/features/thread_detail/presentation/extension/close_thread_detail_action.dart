import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/email_supervisor_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension CloseThreadDetailAction on ThreadDetailController {
  void closeThreadDetailAction(BuildContext? context) {
    if (getBinding<SearchEmailController>()?.searchIsRunning.value == true) {
      mailboxDashBoardController.dispatchRoute(DashboardRoutes.searchEmail);
    } else {
      mailboxDashBoardController.dispatchRoute(DashboardRoutes.thread);
    }
    for (var emailId in emailIdsStatus.keys) {
      final tag = emailId.id.value;
      final controller = getBinding<SingleEmailController>(
        tag: tag,
      );
      if (controller == null) continue;

      controller.closeEmailView(context: context);
      for (var worker in controller.obxListeners) {
        worker.dispose();
      }
      Get.delete<SingleEmailController>(tag: tag);
    }

    reset();
  }
}