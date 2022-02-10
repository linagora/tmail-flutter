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
      drawer: ResponsiveWidget(
        responsiveUtils: responsiveUtils,
        mobile: Container(
            child: MailboxView(),
            width: responsiveUtils.isPortrait(context)
                ? responsiveUtils.getSizeWidthScreen(context)
                : responsiveUtils.getSizeWidthScreen(context) / 2),
        tablet: Container(
            child: MailboxView(),
            width: responsiveUtils.getSizeWidthScreen(context) / 2),
        tabletLarge: Container(
            child: MailboxView(),
            width: responsiveUtils.getSizeWidthScreen(context) * 0.35),
        desktop: SizedBox.shrink()
      ),
      drawerEnableOpenDragGesture: !responsiveUtils.isDesktop(context),
      body: ResponsiveWidget(
        responsiveUtils: responsiveUtils,
        desktop: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: MailboxView()),
              Expanded(flex: 1, child: ThreadView()),
              Expanded(flex: 2, child: EmailView()),
            ],
          ),
        ),
        tabletLarge: Container(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: responsiveUtils.getSizeWidthScreen(context) * 0.35,
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ThreadView()
              ),
              Expanded(child: EmailView()),
            ],
          ),
        ),
        tablet: ThreadView(),
        mobile: ThreadView()),
    );
  }
}