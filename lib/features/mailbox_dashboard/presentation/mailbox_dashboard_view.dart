import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';

class MailboxDashBoardView extends GetWidget<MailboxDashBoardController> {

  final responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: responsiveUtils.isMobile(context)
        ? Container(
            child: MailboxView(),
            width: responsiveUtils.getSizeWidthScreen(context))
        : null,
      drawerEnableOpenDragGesture: responsiveUtils.isMobile(context),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!responsiveUtils.isMobile(context)) Expanded(child: MailboxView()),
            Expanded(
              flex: responsiveUtils.isDesktop(context) ? 1 : 3,
              child: ThreadView(),
            ),
            if (responsiveUtils.isDesktop(context)) Expanded(flex: 2, child: EmailView()),
          ],
        ),
      ),
    );
  }
}