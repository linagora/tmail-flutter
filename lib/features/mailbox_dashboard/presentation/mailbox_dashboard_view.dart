import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/base_mailbox_dashboard_view.dart';
import 'package:tmail_ui_user/features/search/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class MailboxDashBoardView extends BaseMailboxDashBoardView {

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
      drawerEnableOpenDragGesture: responsiveUtils.hasLeftMenuDrawerActive(context),
      body: Stack(children: [
        Obx(() {
          switch(controller.routePath.value) {
            case AppRoutes.THREAD:
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
                  mobile: ThreadView());
            case AppRoutes.EMAIL:
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
            case AppRoutes.SEARCH_EMAIL:
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