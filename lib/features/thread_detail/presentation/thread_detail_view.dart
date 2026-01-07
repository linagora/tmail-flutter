import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/widget/keyboard/keyboard_handler_wrapper.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_app_bar_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_bottom_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/labels/check_label_available_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/vacation_response_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/vacation/widgets/vacation_notification_message_widget.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_detail_action_status.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_details_email_views.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_mail_shortcut_actions_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/on_thread_detail_action_click.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/on_thread_page_changed.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/parsing_email_opened_properties_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_app_bar.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_cupertino_loading_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class ThreadDetailView extends GetWidget<ThreadDetailController> {
  const ThreadDetailView({super.key});
  
  @override
  Widget build(BuildContext context) {
    Widget bodyWidget = Column(
      children: [
        Obx(() {
          return ThreadDetailAppBar(
            responsiveUtils: controller.responsiveUtils,
            imagePaths: controller.imagePaths,
            isSearchRunning: controller.isSearchRunning,
            closeThreadDetailAction: controller.closeThreadDetailAction,
            isThreadDetailEnabled: controller.isThreadDetailEnabled,
            backButtonLabel: _getBackButtonLabel(context),
            threadActionReady: controller.emailsInThreadDetailInfo.isNotEmpty,
            threadDetailIsStarred: controller.threadDetailIsStarred,
            threadDetailCanPermanentlyDelete: controller.threadDetailCanPermanentlyDelete,
            onThreadActionClick: controller.onThreadDetailActionClick,
            onThreadMoreActionClick: controller.onThreadDetailMoreActionClick,
            onOpenAttachmentListAction: controller.isEmailExpandedHasAttachments
                ? () => controller.onOpenAttachmentListAction(
                    controller.responsiveUtils.getSizeScreenHeight(context),
                  )
                : null,
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
          final isLabelAvailable = controller
              .mailboxDashBoardController.isLabelAvailable;

          final labelController =
              controller.mailboxDashBoardController.labelController;

          final threadChildren = isLabelAvailable
            ? controller.getThreadDetailEmailViews(labels: labelController.labels)
            : controller.getThreadDetailEmailViews();

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
            child: Stack(
              children: [
                SingleChildScrollView(
                  controller: controller.scrollController,
                  child: threadBody,
                ),
                ThreadDetailCupertinoLoadingWidget(
                  threadDetailController: controller,
                ),
              ],
            ),
          );

          if (PlatformInfo.isMobile) {
            final manager = controller.threadDetailManager;
            final currentIndex = manager.currentMobilePageViewIndex.value;

            if (currentIndex == -1) return nonPageViewThread;

            return Expanded(
              child: Stack(
                children: [
                  PageView.builder(
                    controller: manager.pageController,
                    itemCount: manager.isThreadDetailEnabled
                        ? manager.availableThreadIds.length
                        : manager.currentDisplayedEmails.length,
                    itemBuilder: (_, __) {
                      return SingleChildScrollView(
                        controller: controller.scrollController,
                        child: threadBody,
                      );
                    },
                    onPageChanged: controller.onThreadPageChanged,
                  ),
                  ThreadDetailCupertinoLoadingWidget(
                    threadDetailController: controller,
                  ),
                ],
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
            userName: controller.ownEmailAddress,
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
      bodyWidget = Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          color: Colors.white,
        ),
        margin: const EdgeInsetsDirectional.only(end: 16, bottom: 16),
        clipBehavior: Clip.antiAlias,
        child: bodyWidget,
      );
    } else {
      bodyWidget = ColoredBox(color: Colors.white, child: bodyWidget);
    }

    if (PlatformInfo.isWeb && controller.keyboardShortcutFocusNode != null) {
      return KeyboardHandlerWrapper(
        onKeyDownEventAction: controller.onKeyDownEventAction,
        focusNode: controller.keyboardShortcutFocusNode!,
        child: bodyWidget,
      );
    } else {
      return bodyWidget;
    }
  }

  String _getBackButtonLabel(BuildContext context) {
    if (controller.isSearchRunning) {
      return '';
    }
    return controller
      .mailboxDashBoardController
      .selectedMailbox
      .value
      ?.getDisplayName(context) ?? '';
  }

  bool showLoadingView(Either<Failure, Success> viewState) {
    final viewStateValue = viewState.fold(id, id);
    return viewStateValue is GettingThreadById &&
      !viewStateValue.updateCurrentThreadDetail;
  }
}