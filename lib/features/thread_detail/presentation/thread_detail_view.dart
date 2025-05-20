import 'package:collection/collection.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/email/email_in_thread_status.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_bottom_bar_widget.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_detail_loading_view.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_details_email_views.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_app_bar.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ThreadDetailView extends GetWidget<ThreadDetailController> {
  const ThreadDetailView({super.key});
  
  @override
  Widget build(BuildContext context) {
    final multipleEmailsView = SafeArea(
      child: Column(
        children: [
          Obx(() => ThreadDetailAppBar(
            responsiveUtils: controller.responsiveUtils,
            imagePaths: controller.imagePaths,
            isSearchRunning: controller.isSearchRunning,
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
            final expandedEmailMap = controller
              .emailIdsPresentation
              .entries
              .firstWhereOrNull(
                (entry) => entry.value?.emailInThreadStatus == EmailInThreadStatus.expanded
              );

            if (expandedEmailMap == null) {
              return _roundBottomPlaceHolder(
                isDesktop: controller.responsiveUtils.isDesktop(context),
              );
            }
            
            final expandedEmailId = expandedEmailMap.key;
            final expandedEmailController = getBinding<SingleEmailController>(
              tag: expandedEmailId.id.value
            );
            if (expandedEmailController == null) {
              return _roundBottomPlaceHolder(
                isDesktop: controller.responsiveUtils.isDesktop(context),
              );
            }

            final expandedPresentationEmail = expandedEmailMap.value;
            final lastEmailLoaded = expandedEmailController.currentEmailLoaded.value;
            if (lastEmailLoaded == null || expandedPresentationEmail == null) {
              return _roundBottomPlaceHolder(
                isDesktop: controller.responsiveUtils.isDesktop(context),
              );
            }

            return Padding(
              padding: controller.responsiveUtils.isDesktop(context)
                ? const EdgeInsetsDirectional.only(end: 16)
                : EdgeInsets.zero,
              child: EmailViewBottomBarWidget(
                key: const Key('email_view_button_bar'),
                imagePaths: expandedEmailController.imagePaths,
                responsiveUtils: expandedEmailController.responsiveUtils,
                emailLoaded: lastEmailLoaded,
                presentationEmail: expandedPresentationEmail,
                userName: expandedEmailController.getOwnEmailAddress(),
                emailActionCallback: expandedEmailController.pressEmailAction,
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

    return Obx(() {
      if (controller.emailIds.length == 1 &&
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