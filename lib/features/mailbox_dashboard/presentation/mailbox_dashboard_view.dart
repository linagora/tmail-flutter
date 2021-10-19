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
      drawer: responsiveUtils.isMobileDevice(context)
        ? Container(
            child: MailboxView(),
            width: responsiveUtils.isPortrait(context)
              ? responsiveUtils.getSizeWidthScreen(context)
              : responsiveUtils.getSizeWidthScreen(context) / 2)
        : null,
      drawerEnableOpenDragGesture: responsiveUtils.isMobileDevice(context),
      body: Container(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (!responsiveUtils.isMobileDevice(context))
              Expanded(
                flex: responsiveUtils.isDesktop(context) ? 1 : 2,
                child: MailboxView()),
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