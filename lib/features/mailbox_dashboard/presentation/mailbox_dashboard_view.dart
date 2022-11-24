import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector/focus_detector.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/base_mailbox_dashboard_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/search/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';

class MailboxDashBoardView extends BaseMailboxDashBoardView {

  MailboxDashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyLandscapeTablet = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: ResponsiveUtils.defaultSizeLeftMenuMobile,
            child: _buildScaffoldHaveDrawer(body: ThreadView())),
        Expanded(child: EmailView()),
      ],
    );

    return FocusDetector(
      onFocusGained: controller.refreshActionWhenBackToApp,
      child: Scaffold(
        drawerEnableOpenDragGesture: responsiveUtils.hasLeftMenuDrawerActive(context),
        body: Stack(children: [
          Obx(() {
            switch(controller.dashboardRoute.value) {
              case DashboardRoutes.thread:
                return ResponsiveWidget(
                    responsiveUtils: responsiveUtils,
                    desktop: controller.searchController.isSearchEmailRunning
                        ? EmailView()
                        : bodyLandscapeTablet,
                    tabletLarge: controller.searchController.isSearchEmailRunning
                        ? EmailView()
                        : bodyLandscapeTablet,
                    landscapeTablet: controller.searchController.isSearchEmailRunning
                        ? EmailView()
                        : bodyLandscapeTablet,
                    mobile: _buildScaffoldHaveDrawer(body: ThreadView()));
              case DashboardRoutes.emailDetailed:
                return ResponsiveWidget(
                    responsiveUtils: responsiveUtils,
                    desktop: controller.searchController.isSearchEmailRunning
                        ? EmailView()
                        : bodyLandscapeTablet,
                    tabletLarge: controller.searchController.isSearchEmailRunning
                        ? EmailView()
                        : bodyLandscapeTablet,
                    landscapeTablet: controller.searchController.isSearchEmailRunning
                        ? EmailView()
                        : bodyLandscapeTablet,
                    mobile: EmailView());
              case DashboardRoutes.searchEmail:
                return SafeArea(child: SearchEmailView());
              default:
                return ResponsiveWidget(
                    responsiveUtils: responsiveUtils,
                    desktop: controller.searchController.isSearchEmailRunning
                        ? EmailView()
                        : bodyLandscapeTablet,
                    tabletLarge: controller.searchController.isSearchEmailRunning
                        ? EmailView()
                        : bodyLandscapeTablet,
                    landscapeTablet: controller.searchController.isSearchEmailRunning
                        ? EmailView()
                        : bodyLandscapeTablet,
                    mobile: _buildScaffoldHaveDrawer(body: ThreadView()));
            }
          }),
        ]),
      ),
    );
  }

  _buildScaffoldHaveDrawer({required Widget body}) {
    return Scaffold(
      key: controller.scaffoldKey,
      body: body,
      drawer: ResponsiveWidget(
        responsiveUtils: responsiveUtils,
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
    );
  }
}