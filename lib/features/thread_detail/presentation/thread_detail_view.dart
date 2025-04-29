import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_app_bar_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_back_button.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_email_ids_by_thread_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_detail_loading_view.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_details_email_views.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ThreadDetailView extends GetWidget<ThreadDetailController> {
  const ThreadDetailView({super.key});

  bool get isSearchActivated => controller
    .mailboxDashBoardController
    .searchController
    .isSearchEmailRunning;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          if (!controller.responsiveUtils.isTabletLarge(context))
            LayoutBuilder(builder: (context, constraints) {
              return Container(
                height: PlatformInfo.isIOS
                  ? EmailViewAppBarWidgetStyles.heightIOS(context, controller.responsiveUtils)
                  : EmailViewAppBarWidgetStyles.height,
                padding: PlatformInfo.isIOS
                  ? EmailViewAppBarWidgetStyles.paddingIOS(context, controller.responsiveUtils)
                  : EmailViewAppBarWidgetStyles.padding,
                margin: !PlatformInfo.isMobile && controller.responsiveUtils.isDesktop(context)
                  ? const EdgeInsetsDirectional.only(end: 16)
                  : EdgeInsets.zero,
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
                        onBackAction: () => controller.closeThreadDetailAction(context),
                        mailboxContain: _getMailboxContain(),
                        isSearchActivated: isSearchActivated,
                        maxWidth: constraints.maxWidth,
                      ),
                  ]);
                })
              );
            }),
          Obx(() => controller.getThreadDetailLoadingView()),
          Obx(() {
            return controller.viewState.value.fold(
              (failure) => const SizedBox.shrink(),
              (success) {
                if (success is GettingEmailIdsByThreadId) {
                  return const SizedBox.shrink();
                }

                return Expanded(
                  child: Padding(
                    padding: _padding(context),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: controller.getThreadDetailEmailViews()
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
          if (controller.responsiveUtils.isDesktop(context))
            const SizedBox(height: 16),
        ],
      ),
    );
  }

  EdgeInsetsGeometry _padding(BuildContext context) {
    if (controller.responsiveUtils.isDesktop(context)) {
      return const EdgeInsetsDirectional.only(end: 16);
    }
    return EdgeInsets.zero;
  }

  PresentationMailbox? _getMailboxContain() {
    if (getBinding<SearchEmailController>()?.searchIsRunning.value == true) {
      return null;
    }

    return controller.mailboxDashBoardController.selectedMailbox.value;
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