import 'package:collection/collection.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/email_supervisor_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/controller/single_email_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/email/presentation/styles/email_view_app_bar_widget_styles.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_back_button.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_status.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/load_more_thread_detail_emails.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/widgets/thread_detail_load_more_circle.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

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
                    onBackAction: () {
                      for (var emailId in controller.emailIdsStatus.keys) {
                        final tag = emailId.id.value;
                        final controller = getBinding<SingleEmailController>(
                          tag: tag,
                        );
                        if (controller == null) continue;
    
                        controller.closeEmailView();
                        for (var worker in controller.obxListeners) {
                          worker.dispose();
                        }
                        Get.delete<SingleEmailController>(tag: tag);
                        Get.delete<EmailSupervisorController>(tag: tag);
                      }
    
                      Get.delete<ThreadDetailController>();
                    },
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
          int? firstEmailNotLoadedIndex;
          if (controller.emailsNotLoadedCount > 0) {
            firstEmailNotLoadedIndex = controller.emailIds.indexOf(
              controller.emailIdsPresentation.entries.firstWhereOrNull(
                (entry) => entry.value == null
              )?.key
            );
          }

          final children = controller.emailIdsPresentation.entries.map((entry) {
            final emailId = entry.key;
            final presentationEmail = entry.value;
            if (presentationEmail == null) {
              if (controller.emailIds.indexOf(emailId) != firstEmailNotLoadedIndex) {
                return const SizedBox.shrink();
              }

              return ThreadDetailLoadMoreCircle(
                count: controller.emailsNotLoadedCount,
                onTap: controller.loadMoreThreadDetailEmails,
                imagePaths: controller.imagePaths,
                isLoading: controller.loadingThreadDetail,
              );
            }
    
            if (controller.emailIdsStatus[emailId] == EmailInThreadStatus.collapsed) {
              return const SizedBox.shrink();
            }
    
            return EmailView(
              key: ValueKey(presentationEmail.id?.id.value),
              presentationEmail: presentationEmail,
              threadDetailLastEmail: emailId == controller.emailIds.last,
            );
          }).toList();
    
          return ListView(children: children);
        })),
        const SizedBox(height: 16),
      ],
    );
  }

  bool _supportDisplayMailboxNameTitle(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return controller.responsiveUtils.isDesktop(context) ||
        controller.responsiveUtils.isMobile(context) ||
        controller.responsiveUtils.isTablet(context) ||
        isSearchActivated;
    } else {
      return controller.responsiveUtils.isPortraitMobile(context) ||
        controller.responsiveUtils.isLandscapeMobile(context) ||
        controller.responsiveUtils.isTablet(context) ||
        isSearchActivated;
    }
  }
}