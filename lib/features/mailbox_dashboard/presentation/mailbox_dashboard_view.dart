import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/responsive/responsive_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/base_mailbox_dashboard_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/sending_queue_view.dart';
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
        const VerticalDivider(width: 12),
        const Expanded(child: EmailView()),
      ],
    );

    return FocusDetector(
      onForegroundGained: controller.handleOnForegroundGained,
      child: Scaffold(
        drawerEnableOpenDragGesture: controller.responsiveUtils.hasLeftMenuDrawerActive(context),
        body: Obx(() {
          var bodyView = controller.searchController.isSearchEmailRunning
            ? const EmailView()
            : bodyLandscapeTablet;
          
          switch(controller.dashboardRoute.value) {
            case DashboardRoutes.thread:
              return ResponsiveWidget(
                  responsiveUtils: controller.responsiveUtils,
                  desktop: bodyView,
                  tabletLarge: bodyView,
                  landscapeTablet: bodyView,
                  mobile: _buildScaffoldHaveDrawer(body: ThreadView()));
            case DashboardRoutes.emailDetailed:
              return ResponsiveWidget(
                  responsiveUtils: controller.responsiveUtils,
                  desktop: bodyView,
                  tabletLarge: bodyView,
                  landscapeTablet: bodyView,
                  mobile: const EmailView());
            case DashboardRoutes.searchEmail:
              return SafeArea(child: SearchEmailView());
            case DashboardRoutes.sendingQueue:
              bodyView = Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: ResponsiveUtils.defaultSizeLeftMenuMobile,
                    child: _buildScaffoldHaveDrawer(body: const SendingQueueView())),
                  const VerticalDivider(width: 12),
                  const Expanded(child: EmailView()),
                ],
              );
              return ResponsiveWidget(
                responsiveUtils: controller.responsiveUtils,
                desktop: bodyView,
                tabletLarge: bodyView,
                landscapeTablet: bodyView,
                mobile: _buildScaffoldHaveDrawer(body: const SendingQueueView()));
            case DashboardRoutes.waiting:
              return const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CupertinoActivityIndicator(color: AppColor.colorLoading)));
            }
        }),
      ),
    );
  }

  _buildScaffoldHaveDrawer({required Widget body}) {
    return Scaffold(
      key: controller.scaffoldKey,
      body: body,
      drawer: ResponsiveWidget(
        responsiveUtils: controller.responsiveUtils,
        mobile: SizedBox(
          width: ResponsiveUtils.mobileLeftMenuSize,
          child: MailboxView()
        ),
        tablet: SizedBox(
          width: ResponsiveUtils.defaultSizeDrawer,
          child: MailboxView()
        ),
        landscapeTablet: SizedBox(
          width: ResponsiveUtils.defaultSizeLeftMenuMobile,
          child: MailboxView()
        ),
        tabletLarge: SizedBox(
          width: ResponsiveUtils.defaultSizeLeftMenuMobile,
          child: MailboxView()
        ),
        desktop: SizedBox(
          width: ResponsiveUtils.defaultSizeLeftMenuMobile,
          child: MailboxView()
        )
      ),
    );
  }
}