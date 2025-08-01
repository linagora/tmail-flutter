import 'package:tmail_ui_user/features/email/presentation/bindings/email_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:model/email/email_in_thread_status.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleGetEmailsByIdsSuccess on ThreadDetailController {
  void handleGetEmailsByIdsSuccess(GetEmailsByIdsSuccess success) {
    final currentRoute = mailboxDashBoardController.dashboardRoute.value;
    if (currentRoute != DashboardRoutes.threadDetailed) {
      return;
    }

    if (success is PreloadEmailsByIdsSuccess) {
      final email = success.presentationEmails.first;
      EmailBindings(currentEmailId: email.id).dependencies();
      currentExpandedEmailId.value = email.id;
      
      if (isThreadDetailEnabled) {
        loadThreadOnThreadChanged = false;
        mailboxDashBoardController.dispatchThreadDetailUIAction(
          LoadThreadDetailAfterSelectedEmailAction(email.threadId!),
        );
      } else {
        emailIdsPresentation[email.id!] = emailIdsPresentation[email.id!]?.copyWith(
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
    emailIdsPresentation[selectedEmailId] = emailIdsPresentation[selectedEmailId]?.copyWith(
      emailInThreadStatus: EmailInThreadStatus.expanded,
    );
    threadDetailManager.currentMobilePageViewIndex.refresh();
  }
}