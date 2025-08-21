import 'package:core/utils/platform_info.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/bindings/email_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:model/email/email_in_thread_status.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleGetEmailsByIdsSuccess on ThreadDetailController {
  Future<void> handleGetEmailsByIdsSuccess(GetEmailsByIdsSuccess success) async {
    final currentRoute = mailboxDashBoardController.dashboardRoute.value;
    if (currentRoute != DashboardRoutes.threadDetailed) {
      return;
    }

    if (success is PreloadEmailsByIdsSuccess &&
        success.presentationEmails.isNotEmpty) {
      final email = success.presentationEmails.first;
      final emailId = email.id;
      if (emailId == null) return;
      EmailBindings(currentEmailId: emailId).dependencies();
      currentExpandedEmailId.value = emailId;
      final isInternetConnected = await networkConnectionController.hasInternetConnection();
      
      if (isThreadDetailEnabled && isInternetConnected) {
        loadThreadOnThreadChanged = false;
        final mailboxContain = email.findMailboxContain(
          mailboxDashBoardController.mapMailboxById,
        );
        mailboxDashBoardController.dispatchThreadDetailUIAction(
          LoadThreadDetailAfterSelectedEmailAction(
            email.threadId!,
            isSentMailbox: mailboxContain?.isSent == true,
          ),
        );
      } else {
        emailIdsPresentation[emailId] = emailIdsPresentation[emailId]?.copyWith(
          emailInThreadStatus: EmailInThreadStatus.expanded,
        );
      }
      return;
    }

    final selectedEmailId = mailboxDashBoardController.selectedEmail.value?.id;
    if (selectedEmailId == null) return;
    
    for (var presentationEmail in success.presentationEmails) {
      if (presentationEmail.id == null) continue;

      if (success.updateCurrentThreadDetail) {
        emailIdsPresentation[presentationEmail.id!] = presentationEmail.copyWith(
          emailInThreadStatus: emailIdsPresentation[presentationEmail.id!]
            ?.emailInThreadStatus ?? EmailInThreadStatus.collapsed,
        );
        continue;
      }

      emailIdsPresentation[presentationEmail.id!] = presentationEmail.copyWith(
        emailInThreadStatus: EmailInThreadStatus.collapsed,
      );
    }
    if (currentExpandedEmailId.value != null) {
      emailIdsPresentation[currentExpandedEmailId.value!] = emailIdsPresentation[currentExpandedEmailId.value!]?.copyWith(
        emailInThreadStatus: EmailInThreadStatus.expanded,
      );
    }
    if (PlatformInfo.isMobile) {
      threadDetailManager.currentMobilePageViewIndex.refresh();
    }
  }
}