import 'package:tmail_ui_user/features/email/presentation/bindings/email_bindings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_routes.dart';
import 'package:model/email/email_in_thread_status.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleGetEmailsByIdsSuccess on ThreadDetailController {
  void handleGetEmailsByIdsSuccess(GetEmailsByIdsSuccess success) {
    final currentRoute = mailboxDashBoardController.dashboardRoute.value;
    if (currentRoute != DashboardRoutes.threadDetailed) {
      return;
    }
    
    if (emailIds.length == 1 && success.presentationEmails.length == 1) {
      closeThreadDetailAction(currentContext);
      getBinding<MailboxDashBoardController>()
        ?.dispatchRoute(DashboardRoutes.thread);
      getBinding<MailboxDashBoardController>()
        ?.openEmailDetailedView(
          success.presentationEmails.first,
          singleEmail: true,
        );
      return;
    }
    
    for (var presentationEmail in success.presentationEmails) {
      if (presentationEmail.id == null) continue;
      if (presentationEmail.id == emailIds.last) {
        EmailBindings(initialEmail: presentationEmail).dependencies();
      }
      emailIdsPresentation[presentationEmail.id!] = presentationEmail.copyWith(
        emailInThreadStatus: presentationEmail.id == emailIds.last
          ? EmailInThreadStatus.expanded
          : EmailInThreadStatus.collapsed,
      );
    }

    scrollReverse.value = false;
  }
}