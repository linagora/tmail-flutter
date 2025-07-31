import 'package:tmail_ui_user/features/email/presentation/bindings/email_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:model/email/email_in_thread_status.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';

extension HandleGetEmailsByIdsSuccess on ThreadDetailController {
  void handleGetEmailsByIdsSuccess(GetEmailsByIdsSuccess success) {
    final currentRoute = mailboxDashBoardController.dashboardRoute.value;
    if (currentRoute != DashboardRoutes.threadDetailed) {
      return;
    }

    final selectedEmailId = mailboxDashBoardController.selectedEmail.value?.id;
    
    for (var presentationEmail in success.presentationEmails) {
      if (presentationEmail.id == null) continue;

      if (success.updateCurrentThreadDetail) {
        emailIdsPresentation[presentationEmail.id!] = presentationEmail.copyWith(
          emailInThreadStatus: emailIdsPresentation[presentationEmail.id!]
            ?.emailInThreadStatus ?? EmailInThreadStatus.collapsed,
        );
        continue;
      }

      if (presentationEmail.id == selectedEmailId) {
        EmailBindings(currentEmailId: presentationEmail.id).dependencies();
        currentExpandedEmailId.value = presentationEmail.id;
      }
      emailIdsPresentation[presentationEmail.id!] = presentationEmail.copyWith(
        emailInThreadStatus: presentationEmail.id == selectedEmailId
          ? EmailInThreadStatus.expanded
          : EmailInThreadStatus.collapsed,
      );
    }
    threadDetailManager.currentMobilePageViewIndex.refresh();
  }
}