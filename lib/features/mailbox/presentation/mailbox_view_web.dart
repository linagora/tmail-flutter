import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:linagora_design_flutter/linagora_design_flutter.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/base_mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/mailbox_sidebar_footer.dart';

class MailboxView extends BaseMailboxView {

  MailboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDesktop = controller.responsiveUtils.isDesktop(context);

    return Drawer(
      backgroundColor: isDesktop ? AppColor.colorBgDesktop : Colors.white,
      shape: InputBorder.none,
      shadowColor: AppColor.blackAlpha20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isDesktop) buildMailboxAppBar(),
          Expanded(child: _buildSidebarMenu(context, isDesktop)),
        ],
      ),
    );
  }

  Widget _buildSidebarMenu(BuildContext context, bool isDesktop) {
    final sidebarMenu = buildSidebarMenu(
      context,
      footerItems: [
        MailboxSidebarFooter(
          isDesktop: isDesktop,
          showIncreaseSpaceButton: true,
        ),
      ],
      bodyOverlay: Obx(() => LinagoraSidebarAutoScrollOverlay(
        isDragging: controller.mailboxDashBoardController.isDraggingMailbox,
      )),
    );

    final isCanvasKit = PlatformInfo.isCanvasKit;

    return ScrollbarListView(
      scrollController: controller.mailboxListScrollController,
      scrollBehavior: isCanvasKit
          ? null
          : ScrollConfiguration.of(context).copyWith(
              physics: const BouncingScrollPhysics(),
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
              scrollbars: false,
            ),
      child: isCanvasKit
          ? sidebarMenu
          : RefreshIndicator(
              color: AppColor.primaryColor,
              onRefresh: controller.refreshAllMailbox,
              child: sidebarMenu,
            ),
    );
  }
}
