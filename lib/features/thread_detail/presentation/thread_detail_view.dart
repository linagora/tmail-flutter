import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_bottom_bar_widget.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_detail_loading_view.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_details_email_views.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_app_bar.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ThreadDetailView extends GetWidget<ThreadDetailController> {
  const ThreadDetailView({super.key});
  
  bool get isSearchRunning {
    final isWebSearchRunning = controller
      .mailboxDashBoardController
      .searchController
      .isSearchEmailRunning;
    final isMobileSearchRunning = getBinding<SearchEmailController>()
      ?.searchIsRunning
      .value == true;
    return isWebSearchRunning || isMobileSearchRunning;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          if (!controller.responsiveUtils.isTabletLarge(context))
            Obx(() => ThreadDetailAppBar(
              responsiveUtils: controller.responsiveUtils,
              imagePaths: controller.imagePaths,
              isSearchRunning: isSearchRunning,
              closeThreadDetailAction: controller.closeThreadDetailAction,
              lastEmailOfThread: controller.emailIdsPresentation.values.lastOrNull,
              ownUserName: controller.session?.username.value ?? '',
              mailboxContain: _getMailboxContain(),
              emailLoaded: getBinding<SingleEmailController>(
                tag: controller.emailIds.lastOrNull?.id.value
              )?.currentEmailLoaded.value,
              onEmailActionClick: (email, action) {
                // TODO: Next PR
              },
              onMoreActionClick: (p0, p1) {
                // TODO: Next PR
              },
              optionWidgets: PlatformInfo.isMobile ? [] : [
                TMailButtonWidget.fromIcon(
                  icon: DirectionUtils.isDirectionRTLByLanguage(context)
                    ? controller.imagePaths.icOlder
                    : controller.imagePaths.icNewer,
                  iconColor: EmailViewStyles.iconColor,
                  iconSize: EmailViewStyles.pageViewIconSize,
                  backgroundColor: Colors.transparent,
                  tooltipMessage: AppLocalizations.of(context).newer,
                  onTapActionCallback: () {
                    // TODO: Next PR
                  },
                ),
                TMailButtonWidget.fromIcon(
                  icon: DirectionUtils.isDirectionRTLByLanguage(context)
                    ? controller.imagePaths.icNewer
                    : controller.imagePaths.icOlder,
                  iconColor: EmailViewStyles.iconColor,
                  iconSize: EmailViewStyles.pageViewIconSize,
                  backgroundColor: Colors.transparent,
                  tooltipMessage: AppLocalizations.of(context).older,
                  onTapActionCallback: () {
                    // TODO: Next PR
                  }
                ),
                const SizedBox(width: 16),
              ],
            )),
          Obx(() => controller.getThreadDetailLoadingView(
            isResponsiveDesktop: controller.responsiveUtils.isDesktop(context),
          )),
          Obx(() {
            return controller.viewState.value.fold(
              (failure) => const SizedBox.shrink(),
              (success) {
                if (success is GettingThreadById) {
                  return const SizedBox.shrink();
                }

                return Expanded(
                  child: Padding(
                    padding: _padding(context),
                    child: Stack(
                      children: [
                        const Positioned.fill(
                          child: ColoredBox(color: Colors.white),
                        ),
                        SingleChildScrollView(
                          reverse: true,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: controller.getThreadDetailEmailViews()
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
          Obx(() {
            final lastEmailController = getBinding<SingleEmailController>(
              tag: controller.emailIds.lastOrNull?.id.value
            );
            if (lastEmailController == null) {
              return const SizedBox.shrink();
            }
            final lastEmailLoaded = lastEmailController.currentEmailLoaded.value;
            final lastEmail = controller.emailIdsPresentation.values.lastOrNull;
            if (lastEmailLoaded == null || lastEmail == null) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: controller.responsiveUtils.isDesktop(context)
                ? const EdgeInsetsDirectional.only(end: 16)
                : EdgeInsets.zero,
              child: EmailViewBottomBarWidget(
                key: const Key('email_view_button_bar'),
                imagePaths: lastEmailController.imagePaths,
                responsiveUtils: lastEmailController.responsiveUtils,
                emailLoaded: lastEmailLoaded,
                presentationEmail: lastEmail,
                userName: lastEmailController.getOwnEmailAddress(),
                emailActionCallback: lastEmailController.pressEmailAction,
                bottomBarDecoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppColor.colorDividerEmailView),
                  ),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(20),
                  ),
                ),
                padding: EdgeInsets.zero,
              ),
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
    if (isSearchRunning) {
      return null;
    }

    return controller.mailboxDashBoardController.selectedMailbox.value;
  }
}