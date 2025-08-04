import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_app_bar_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_bottom_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_open_context_menu_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_detail_email_mailbox_contains.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_details_email_views.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/on_thread_page_changed.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/thread_detail_on_email_action_click.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_app_bar.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';

class ThreadDetailView extends GetWidget<ThreadDetailController> {
  const ThreadDetailView({super.key});
  
  @override
  Widget build(BuildContext context) {
    Widget bodyWidget = Column(
      children: [
        Obx(() {
          final isLoading = showLoadingView(controller.viewState.value);

          return ThreadDetailAppBar(
            responsiveUtils: controller.responsiveUtils,
            imagePaths: controller.imagePaths,
            isSearchRunning: controller.isSearchRunning,
            closeThreadDetailAction: controller.closeThreadDetailAction,
            lastEmailOfThread: controller.emailIdsPresentation.values.lastOrNull,
            ownUserName: controller.session?.getOwnEmailAddress() ?? '',
            isThreadDetailEnabled: controller.isThreadDetailEnabled,
            mailboxContain: _getMailboxContain(),
            onEmailActionClick: isLoading
                ? null
                : controller.threadDetailOnEmailActionClick,
            onMoreActionClick: (presentationEmail, position) => isLoading
                ? null
                : controller.emailActionReactor.handleMoreEmailAction(
              mailboxContain: controller.getThreadDetailEmailMailboxContains(
                presentationEmail,
              ),
              presentationEmail: presentationEmail,
              position: position,
              responsiveUtils: controller.responsiveUtils,
              imagePaths: controller.imagePaths,
              username: controller.session?.username,
              handleEmailAction: controller.threadDetailOnEmailActionClick,
              additionalActions: [
                if (controller.responsiveUtils.isMobile(context)) ...[
                  EmailActionType.forward,
                  EmailActionType.replyAll,
                  EmailActionType.replyToList,
                ],
                EmailActionType.markAsStarred,
                EmailActionType.unMarkAsStarred,
                EmailActionType.moveToTrash,
                EmailActionType.deletePermanently,
                EmailActionType.printAll,
                EmailActionType.moveToMailbox,
              ],
              emailIsRead: presentationEmail.hasRead,
              openBottomSheetContextMenu: controller.mailboxDashBoardController.openBottomSheetContextMenu,
              openPopupMenu: controller.mailboxDashBoardController.openPopupMenu,
            ),
            optionWidgets: [
              if (controller.previousAvailable)
                TMailButtonWidget.fromIcon(
                  icon: controller.imagePaths.icNewer,
                  iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
                  iconColor: EmailViewAppBarWidgetStyles.iconColor,
                  tooltipMessage: AppLocalizations.of(context).newer,
                  backgroundColor: Colors.transparent,
                  onTapActionCallback: controller.onPrevious,
                ),
              if (controller.nextAvailable)
                TMailButtonWidget.fromIcon(
                  icon: controller.imagePaths.icOlder,
                  iconSize: EmailViewAppBarWidgetStyles.buttonIconSize,
                  iconColor: EmailViewAppBarWidgetStyles.iconColor,
                  tooltipMessage: AppLocalizations.of(context).older,
                  backgroundColor: Colors.transparent,
                  onTapActionCallback: controller.onNext,
                ),
            ],
          );
        }),
        Obx(() {
          final vacation = controller.mailboxDashBoardController.vacationResponse.value;

          bool isPlatformSupportVacationVisible =
              controller.responsiveUtils.isMobile(context) ||
                  controller.responsiveUtils.isTablet(context) ||
                  controller.responsiveUtils.isLandscapeMobile(context);

          bool isVacationBannerVisible =
              vacation?.vacationResponderIsValid == true &&
                  isPlatformSupportVacationVisible;

          if (isVacationBannerVisible) {
            return VacationNotificationMessageWidget(
              margin: const EdgeInsetsDirectional.only(
                start: 12,
                end: 12,
                top: 8,
              ),
              vacationResponse: vacation!,
              actionGotoVacationSetting: controller.mailboxDashBoardController.goToVacationSetting,
              actionEndNow: controller.mailboxDashBoardController.disableVacationResponder,
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        Obx(() {
          final threadChildren = controller.getThreadDetailEmailViews();

          late Widget threadBody;

          if (threadChildren.length == 1) {
            threadBody = threadChildren.first;
          } else {
            threadBody = Column(
              mainAxisSize: MainAxisSize.min,
              children: threadChildren,
            );
          }

          final nonPageViewThread = Expanded(
            child: SingleChildScrollView(
              controller: controller.scrollController,
              child: threadBody,
            ),
          );

          if (PlatformInfo.isMobile) {
            final manager = controller.threadDetailManager;
            final currentIndex = manager.currentMobilePageViewIndex.value;

            if (currentIndex == -1) return nonPageViewThread;

            return Expanded(
              child: PageView.builder(
                controller: manager.pageController,
                itemCount: manager.isThreadDetailEnabled
                    ? manager.availableThreadIds.length
                    : manager.currentDisplayedEmails.length,
                itemBuilder: (context, index) {
                  if (index != currentIndex) {
                    return const SizedBox.shrink();
                  }
                  return SingleChildScrollView(child: threadBody);
                },
                onPageChanged: controller.onThreadPageChanged,
              ),
            );
          }

          return nonPageViewThread;
        }),
        Obx(() {
          final expandedEmailId = controller.currentExpandedEmailId.value;
          if (expandedEmailId == null) {
            return const SizedBox.shrink();
          }
          final expandedPresentationEmail = controller.emailIdsPresentation[expandedEmailId];
          if (expandedPresentationEmail == null) {
            return const SizedBox.shrink();
          }

          final currentEmailLoaded = controller.currentEmailLoaded.value;
          if (currentEmailLoaded == null) {
            return const SizedBox.shrink();
          }

          return EmailViewBottomBarWidget(
            key: const Key('email_view_button_bar'),
            imagePaths: controller.imagePaths,
            responsiveUtils: controller.responsiveUtils,
            emailLoaded: currentEmailLoaded,
            presentationEmail: expandedPresentationEmail,
            userName: controller.session?.getOwnEmailAddress() ?? '',
            emailActionCallback: (action, email) {
              controller.mailboxDashBoardController
                ..dispatchEmailUIAction(PerformEmailActionInThreadDetailAction(
                  emailActionType: action,
                  presentationEmail: email,
                ))
                ..dispatchEmailUIAction(EmailUIAction());
            },
            bottomBarDecoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: AppColor.colorDividerEmailView),
              ),
            ),
            padding: EdgeInsets.zero,
          );
        }),
      ],
    );

    if (PlatformInfo.isMobile) {
      bodyWidget = SafeArea(child: bodyWidget);
    }

    if (PlatformInfo.isWeb) {
      bodyWidget = SelectionArea(child: bodyWidget);
    }

    if (controller.responsiveUtils.isDesktop(context)) {
      return Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        margin: const EdgeInsetsDirectional.only(end: 16, bottom: 16),
        clipBehavior: Clip.antiAlias,
        child: bodyWidget,
      );
    } else {
      return ColoredBox(color: Colors.white, child: bodyWidget);
    }
  }

  PresentationMailbox? _getMailboxContain() {
    if (controller.isSearchRunning) {
      return null;
    }

    return controller.mailboxDashBoardController.selectedMailbox.value;
  }

  bool showLoadingView(Either<Failure, Success> viewState) {
    final viewStateValue = viewState.fold(id, id);
    return viewStateValue is GettingThreadById &&
      !viewStateValue.updateCurrentThreadDetail;
  }
}