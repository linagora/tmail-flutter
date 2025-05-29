import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/app_loader_mixin.dart';
import 'package:tmail_ui_user/features/home/domain/extensions/session_extensions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/open_app_grid_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mixin/mailbox_widget_mixin.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_app_bar.dart';

abstract class BaseMailboxView extends GetWidget<MailboxController>
    with
        AppLoaderMixin,
        MailboxWidgetMixin {

  BaseMailboxView({Key? key}) : super(key: key);

  Widget buildMailboxAppBar() {
    return Obx(() {
      final dashboardController = controller.mailboxDashBoardController;
      final accountId = dashboardController.accountId.value;
      final session = dashboardController.sessionCurrent;
      final username = accountId != null
          ? dashboardController.getOwnEmailAddress()
          : '';

      final linagoraApps = dashboardController
          .appGridDashboardController
          .listLinagoraApp;

      final contactSupportCapability = accountId != null && session != null
          ? session.getContactSupportCapability(accountId)
          : null;

      return MailboxAppBar(
        imagePaths: controller.imagePaths,
        username: username,
        openSettingsAction: dashboardController.goToSettings,
        openAppGridAction: linagoraApps.isNotEmpty
          ? () => controller.openAppGrid(linagoraApps)
          : null,
        openContactSupportAction: contactSupportCapability?.isAvailable == true
          ? () => dashboardController.onGetHelpOrReportBug(contactSupportCapability!)
          : null,
      );
    });
  }
}