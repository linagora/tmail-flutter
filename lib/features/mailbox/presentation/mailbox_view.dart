import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/base_mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/sidebar/mailbox_sidebar_footer.dart';

class MailboxView extends BaseMailboxView {

  MailboxView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: InputBorder.none,
      shadowColor: AppColor.blackAlpha20,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PopScope(
              canPop: false,
              onPopInvokedWithResult: (_, __) {
                if (!PlatformInfo.isAndroid) return;
                controller.mailboxDashBoardController.closeMailboxMenuDrawer();
              },
              child: buildMailboxAppBar(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColor.primaryColor,
                onRefresh: controller.refreshAllMailbox,
                notificationPredicate:
                    ScrollbarListView.isVerticalScrollNotification,
                child: buildSidebarMenu(
                  context,
                  footerItems: const [MailboxSidebarFooter()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
