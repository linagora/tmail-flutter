import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_app_bar_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_back_button.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_details_email_views.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

class ThreadDetailView extends StatefulWidget {
  const ThreadDetailView({super.key});

  @override
  State<ThreadDetailView> createState() => _ThreadDetailViewState();
}

class _ThreadDetailViewState extends State<ThreadDetailView> {
  final controller = Get.find<ThreadDetailController>();

  bool get isSearchActivated => controller
    .mailboxDashBoardController
    .searchController
    .isSearchEmailRunning;

  @override
  void dispose() {
    Get.delete<ThreadDetailController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(builder: (context, constraints) {
          return Container(
            height: PlatformInfo.isIOS
              ? EmailViewAppBarWidgetStyles.heightIOS(context, controller.responsiveUtils)
              : EmailViewAppBarWidgetStyles.height,
            padding: PlatformInfo.isIOS
              ? EmailViewAppBarWidgetStyles.paddingIOS(context, controller.responsiveUtils)
              : EmailViewAppBarWidgetStyles.padding,
            margin: PlatformInfo.isMobile
                ? EdgeInsets.zero
                : controller.responsiveUtils.isDesktop(context)
                  ? const EdgeInsetsDirectional.only(end: 16)
                  : const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: EmailViewAppBarWidgetStyles.bottomBorderColor,
                  width: EmailViewAppBarWidgetStyles.bottomBorderWidth,
                )
              ),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(EmailViewAppBarWidgetStyles.radius),
              ),
              color: EmailViewAppBarWidgetStyles.backgroundColor,
            ),
            child: Obx(() {
              return Row(children: [
                if (_supportDisplayMailboxNameTitle(context))
                  EmailViewBackButton(
                    imagePaths: controller.imagePaths,
                    onBackAction: controller.closeThreadDetailAction,
                    mailboxContain: controller
                      .mailboxDashBoardController
                      .selectedMailbox
                      .value,
                    isSearchActivated: isSearchActivated,
                    maxWidth: constraints.maxWidth,
                  ),
              ]);
            })
          );
        }),
        Expanded(child: Obx(() {
          return ListView(children: controller.getThreadDetailEmailViews());
        })),
        const SizedBox(height: 16),
      ],
    );
  }

  bool _supportDisplayMailboxNameTitle(BuildContext context) {
    final isSupportedDevice = PlatformInfo.isWeb
      ? controller.responsiveUtils.isDesktop(context)
          || controller.responsiveUtils.isMobile(context)
          || controller.responsiveUtils.isTablet(context)
      : controller.responsiveUtils.isPortraitMobile(context)
          || controller.responsiveUtils.isLandscapeMobile(context)
          || controller.responsiveUtils.isTablet(context);
    return isSupportedDevice || isSearchActivated;
  }
}