import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/network_connection_mixin.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class MailboxDashBoardView extends GetWidget<MailboxDashBoardController>
    with NetworkConnectionMixin {

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  MailboxDashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyLandscapeTablet = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: ResponsiveUtils.defaultSizeLeftMenuMobile,
            child: ThreadView()),
        Expanded(child: EmailView()),
      ],
    );

    return Scaffold(
      key: controller.scaffoldKey,
      drawer: ResponsiveWidget(
        responsiveUtils: _responsiveUtils,
        mobile: SizedBox(child: MailboxView(), width: double.infinity),
        landscapeMobile: SizedBox(
            child: MailboxView(),
            width: ResponsiveUtils.defaultSizeDrawer),
        tablet: SizedBox(
            child: MailboxView(),
            width: ResponsiveUtils.defaultSizeDrawer),
        landscapeTablet: SizedBox(
            child: MailboxView(),
            width: ResponsiveUtils.defaultSizeLeftMenuMobile),
        tabletLarge: SizedBox(
            child: MailboxView(),
            width: ResponsiveUtils.defaultSizeLeftMenuMobile),
        desktop: SizedBox(
            child: MailboxView(),
            width: ResponsiveUtils.defaultSizeLeftMenuMobile)),
      drawerEnableOpenDragGesture: _responsiveUtils.hasLeftMenuDrawerActive(context),
      body: Stack(children: [
        Obx(() {
          switch(controller.routePath.value) {
            case AppRoutes.THREAD:
              return ResponsiveWidget(
                  responsiveUtils: _responsiveUtils,
                  desktop: bodyLandscapeTablet,
                  tabletLarge: bodyLandscapeTablet,
                  landscapeTablet: bodyLandscapeTablet,
                  mobile: ThreadView());
            case AppRoutes.EMAIL:
              return ResponsiveWidget(
                  responsiveUtils: _responsiveUtils,
                  desktop: bodyLandscapeTablet,
                  tabletLarge: bodyLandscapeTablet,
                  landscapeTablet: bodyLandscapeTablet,
                  mobile: EmailView());
            default:
              return ResponsiveWidget(
                  responsiveUtils: _responsiveUtils,
                  desktop: bodyLandscapeTablet,
                  tabletLarge: bodyLandscapeTablet,
                  landscapeTablet: bodyLandscapeTablet,
                  mobile: ThreadView());
          }
        }),
        Obx(() {
          if (controller.isNetworkConnectionAvailable()) {
            return const SizedBox.shrink();
          }
          return Align(
              alignment: Alignment.bottomCenter,
              child: buildNetworkConnectionWidget(context));
        }),
      ]),
    );
  }
}