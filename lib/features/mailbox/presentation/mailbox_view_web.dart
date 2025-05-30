import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/application_version_widget.dart';
import 'package:tmail_ui_user/features/base/widget/scrollbar_list_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/base_mailbox_view.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

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
            Expanded(
              child: isDesktop
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(start: 16),
                    child: _buildListMailbox(context),
                  )
                : _buildListMailbox(context),
            ),
            const QuotasView(),
            Container(
              alignment: isDesktop
                ? AlignmentDirectional.center
                : AlignmentDirectional.centerStart,
              padding: const EdgeInsetsDirectional.only(
                bottom: 16,
                start: 24,
                end: 24,
              ),
              child: ApplicationVersionWidget(
                title: '${AppLocalizations.of(context).version.toLowerCase()} ',
                textStyle: isDesktop
                  ? ThemeUtils.textStyleContentCaption()
                  : null,
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildListMailbox(BuildContext context) {
    final mailboxListWidget = buildListMailbox(context);

    return Stack(
      children: [
        if (!PlatformInfo.isCanvasKit)
          ScrollbarListView(
            scrollController: controller.mailboxListScrollController,
            scrollBehavior: ScrollConfiguration.of(context).copyWith(
              physics: const BouncingScrollPhysics(),
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad
              },
              scrollbars: false
            ),
            child: RefreshIndicator(
              color: AppColor.primaryColor,
              onRefresh: controller.refreshAllMailbox,
              child: mailboxListWidget,
            ),
          )
        else
          ScrollbarListView(
            scrollController: controller.mailboxListScrollController,
            child: mailboxListWidget
          ),
        Obx(() => controller.mailboxDashBoardController.isDraggingMailbox && controller.activeScrollTop
            ? Align(
                alignment: Alignment.topCenter,
                child: InkWell(
                  onTap: () {},
                  onHover: (value) => value ? controller.autoScrollTop() : controller.stopAutoScroll(),
                  child: Container(
                    height: 40)))
            : const SizedBox.shrink()),
        Obx(() => controller.mailboxDashBoardController.isDraggingMailbox && controller.activeScrollBottom
            ? Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () {},
                  onHover: (value) => value ? controller.autoScrollBottom() : controller.stopAutoScroll(),
                  child: Container(
                    height: 40)))
            : const SizedBox.shrink()),
      ],
    );
  }
}