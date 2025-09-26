import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_empty_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/base_mailbox_dashboard_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/sending_queue_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_view.dart';

class MailboxDashBoardView extends BaseMailboxDashBoardView {
  MailboxDashBoardView({Key? key}) : super(key: key);

  Widget _loadingIndicator() {
    return const Center(
      child: SizedBox(
        width: 30,
        height: 30,
        child: CupertinoActivityIndicator(
          color: AppColor.colorLoading,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onForegroundGained: controller.handleOnForegroundGained,
      child: Scaffold(
        drawerEnableOpenDragGesture:
            controller.responsiveUtils.hasLeftMenuDrawerActive(context),
        body: Obx(() {
          switch (controller.dashboardRoute.value) {
            case DashboardRoutes.thread:
              return buildResponsiveWithDrawer(
                left: ThreadView(),
                right: const EmailViewEmptyWidget(),
                mobile: buildScaffoldHaveDrawer(body: ThreadView()),
              );

            case DashboardRoutes.threadDetailed:
              return controller.searchController.isSearchEmailRunning
                  ? const ThreadDetailView()
                  : buildResponsiveWithDrawer(
                      left: ThreadView(),
                      right: const ThreadDetailView(),
                      mobile: const ThreadDetailView(),
                    );

            case DashboardRoutes.searchEmail:
              return SafeArea(child: SearchEmailView());

            case DashboardRoutes.sendingQueue:
              return buildScaffoldHaveDrawer(body: const SendingQueueView());

            case DashboardRoutes.waiting:
              return _loadingIndicator();
          }
        }),
      ),
    );
  }
}
