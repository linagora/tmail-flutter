import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/mixin/network_connection_mixin.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/action/dashboard_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/app_setting.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/reading_pane.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

class MailboxDashBoardView extends GetWidget<MailboxDashBoardController> with NetworkConnectionMixin {

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  MailboxDashBoardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: ResponsiveWidget(
        responsiveUtils: _responsiveUtils,
        mobile: SizedBox(child: MailboxView(), width: double.infinity),
        landscapeMobile: SizedBox(child: MailboxView(), width: _responsiveUtils.defaultSizeDrawer),
        tablet: SizedBox(child: MailboxView(), width: _responsiveUtils.defaultSizeDrawer),
        tabletLarge: const SizedBox.shrink(),
        desktop: const SizedBox.shrink(),
      ),
      drawerEnableOpenDragGesture: _responsiveUtils.isMobile(context)
          || _responsiveUtils.isLandscapeMobile(context)
          || _responsiveUtils.isTablet(context),
      body: Stack(children: [
        ResponsiveWidget(
          responsiveUtils: _responsiveUtils,
          desktop: _buildLargeScreenView(context),
          tabletLarge: _buildLargeScreenView(context),
          tablet: ThreadView(),
          landscapeMobile: ThreadView(),
          mobile: ThreadView(),
        ),
        Obx(() => controller.dashBoardAction.value is ComposeEmailAction
          ? ComposerView()
          : const SizedBox.shrink()),
        Obx(() => controller.isNetworkConnectionAvailable()
          ? const SizedBox.shrink()
          : Align(alignment: Alignment.bottomCenter, child: buildNetworkConnectionWidget(context))),
      ]),
    );
  }

  Widget _wrapContainerForThreadAndEmail(BuildContext context) {
    switch(AppSetting.readingPane) {
      case ReadingPane.noSplit:
        return Obx(() {
          switch(controller.routePath.value) {
            case AppRoutes.THREAD:
              return ThreadView();
            case AppRoutes.EMAIL:
              return EmailView();
            default:
              return const SizedBox.shrink();
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
        return const SizedBox.shrink();
    }
  }

  Widget _buildLargeScreenView(BuildContext context) {
    if (controller.isDrawerOpen && (_responsiveUtils.isDesktop(context) || _responsiveUtils.isTabletLarge(context))) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        controller.closeMailboxMenuDrawer();
      });
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(child: MailboxView(), width: _responsiveUtils.defaultSizeDrawer),
        Expanded(child: _wrapContainerForThreadAndEmail(context))
      ],
    );
  }
}