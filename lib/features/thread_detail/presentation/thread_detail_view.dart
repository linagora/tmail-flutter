import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_bottom_bar_widget.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/get_mailbox_contain_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_detail_loading_view.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_details_email_views.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/thread_detail_on_email_action_click.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_app_bar.dart';

class ThreadDetailView extends GetWidget<ThreadDetailController> {
  const ThreadDetailView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final multipleEmailsView = SelectionArea(child: SafeArea(
      child: Column(
        children: [
          Obx(() {
            final currentViewState = controller.viewState.value.fold(id, id);
            if (currentViewState is GettingThreadById) {
              return const SizedBox.shrink();
            }

            return ThreadDetailAppBar(
              responsiveUtils: controller.responsiveUtils,
              imagePaths: controller.imagePaths,
              isSearchRunning: controller.isSearchRunning,
              closeThreadDetailAction: controller.closeThreadDetailAction,
              lastEmailOfThread: controller.emailIdsPresentation.values.lastOrNull,
              ownUserName: controller.session?.getOwnEmailAddress() ?? '',
              mailboxContain: _getMailboxContain(),
              onEmailActionClick: controller.threadDetailOnEmailActionClick,
              onMoreActionClick: (presentationEmail, position) => controller.emailActionReactor.handleMoreEmailAction(
                mailboxContain: controller.mailboxDashBoardController.getMailboxContain(presentationEmail),
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
                  EmailActionType.unMarkAsStarred
                ],
              ),
            );
          }),
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
                          controller: controller.scrollController,
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
            final currentViewState = controller.viewState.value.fold(id, id);
            if (currentViewState is GettingThreadById) {
              return const SizedBox.shrink();
            }

            final expandedEmailId = controller.currentExpandedEmailId.value;
            if (expandedEmailId == null) {
              return _roundBottomPlaceHolder(
                isDesktop: controller.responsiveUtils.isDesktop(context),
              );
            }
            final expandedPresentationEmail = controller.emailIdsPresentation[expandedEmailId];
            if (expandedPresentationEmail == null) {
              return _roundBottomPlaceHolder(
                isDesktop: controller.responsiveUtils.isDesktop(context),
              );
            }

            final currentEmailLoaded = controller.currentEmailLoaded.value;
            if (currentEmailLoaded == null) {
              return _roundBottomPlaceHolder(
                isDesktop: controller.responsiveUtils.isDesktop(context),
              );
            }

            return Padding(
              padding: controller.responsiveUtils.isDesktop(context)
                ? const EdgeInsetsDirectional.only(end: 16)
                : EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20),
                ),
                child: EmailViewBottomBarWidget(
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
                ),
              ),
            );
          }),
          if (controller.responsiveUtils.isDesktop(context))
            const SizedBox(height: 16),
        ],
      ),
    ));

    return Obx(() {
      final currentViewState = controller.viewState.value.fold(id, id);
      if (currentViewState is GettingThreadById &&
          controller.responsiveUtils.isTabletLarge(context)) {
        return controller.getThreadDetailLoadingView(isResponsiveDesktop: false);
      }

      if (controller.emailIdsPresentation.length == 1 &&
          controller.emailIdsPresentation.values.firstOrNull != null) {
        return EmailView(
          emailId: controller.emailIdsPresentation.values.firstOrNull?.id,
        );
      }

      return multipleEmailsView;
    });
  }

  EdgeInsetsGeometry _padding(BuildContext context) {
    if (controller.responsiveUtils.isDesktop(context)) {
      return const EdgeInsetsDirectional.only(end: 16);
    }
    return EdgeInsets.zero;
  }

  PresentationMailbox? _getMailboxContain() {
    if (controller.isSearchRunning) {
      return null;
    }

    return controller.mailboxDashBoardController.selectedMailbox.value;
  }

  Widget _roundBottomPlaceHolder({required bool isDesktop}) {
    return Container(
      height: 40,
      margin: isDesktop
        ? const EdgeInsetsDirectional.only(end: 16)
        : EdgeInsets.zero,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      )
    );
  }
}