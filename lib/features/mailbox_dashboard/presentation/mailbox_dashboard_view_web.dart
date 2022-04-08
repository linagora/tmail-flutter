import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/network_connection_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view_web.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_action.dart';
import 'package:tmail_ui_user/features/setting/presentation/model/app_setting.dart';
import 'package:tmail_ui_user/features/setting/presentation/model/reading_pane.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class MailboxDashBoardView extends GetWidget<MailboxDashBoardController> with NetworkConnectionMixin {

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: ResponsiveWidget(
          responsiveUtils: _responsiveUtils,
          mobile: Container(child: MailboxView(),
              width: _responsiveUtils.isPortrait(context) ? _responsiveUtils.getSizeScreenWidth(context) : _responsiveUtils.getSizeScreenWidth(context) / 2),
          tablet: Container(child: MailboxView(), width: _responsiveUtils.getSizeScreenWidth(context) / 2),
          tabletLarge: SizedBox.shrink(),
          desktop: SizedBox.shrink()
      ),
      drawerEnableOpenDragGesture: !_responsiveUtils.isDesktop(context),
      body: Stack(children: [
        ResponsiveWidget(
            responsiveUtils: _responsiveUtils,
            desktop: _buildDesktopView(context),
            tabletLarge: _buildTabletLargeView(context),
            tablet: ThreadView(),
            mobile: ThreadView()
        ),
        Obx(() => controller.dashBoardAction == DashBoardAction.compose
            ? ComposerView()
            : SizedBox.shrink()),
        Obx(() => controller.isNetworkConnectionAvailable()
            ? SizedBox.shrink()
            : Align(alignment: Alignment.bottomCenter, child: buildNetworkConnectionWidget(context))),
      ]),
    );
  }

  Widget _buildThreadAndEmailContainer(BuildContext context) {
    switch(AppSetting.readingPane) {
      case ReadingPane.noSplit:
        return Obx(() {
          switch(controller.routePath.value) {
            case AppRoutes.THREAD:
              return ThreadView();
            case AppRoutes.EMAIL:
              return EmailView();
            default:
              return SizedBox.shrink();
          }
        });
      case ReadingPane.rightOfInbox:
        if (_responsiveUtils.isDesktop(context)) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: ThreadView()),
              Expanded(flex: 2, child: EmailView()),
            ],
          );
        } else {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: ThreadView()),
              Expanded(flex: 1, child: EmailView()),
            ],
          );
        }
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildDesktopView(BuildContext context) {
    if (controller.isDrawerOpen && _responsiveUtils.isDesktop(context)) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        controller.closeDrawer();
      });
    }

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: MailboxView()),
          Expanded(flex: 3, child: _buildThreadAndEmailContainer(context)),
        ],
      ),
    );
  }

  Widget _buildTabletLargeView(BuildContext context) {
    if (controller.isDrawerOpen && _responsiveUtils.isTabletLarge(context)) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        controller.closeDrawer();
      });
    }

    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: MailboxView()),
          Expanded(flex: 4, child: _buildThreadAndEmailContainer(context)),
        ],
      ),
    );
  }
}