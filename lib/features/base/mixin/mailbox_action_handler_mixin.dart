
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/navigation_router.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

mixin MailboxActionHandlerMixin {

  void openMailboxInNewTabAction(PresentationMailbox mailbox) {
    final mailboxRouteWeb = RouteUtils.generateRouteBrowser(
      AppRoutes.dashboard,
      NavigationRouter(mailboxId: mailbox.id)
    );
    log('MailboxActionHandlerMixin::openMailboxInNewTabAction(): mailboxRouteWeb: $mailboxRouteWeb');
    AppUtils.launchLink(mailboxRouteWeb.toString());
  }

  void markAsReadMailboxAction(
    BuildContext context,
    PresentationMailbox presentationMailbox,
    MailboxDashBoardController dashboardController,
    {
      Function(BuildContext)? onCallbackAction
    }
  ) {
    final accountId = dashboardController.accountId.value;
    final mailboxId = presentationMailbox.id;
    final mailboxName = presentationMailbox.name;
    final countEmailsUnread = presentationMailbox.unreadEmails?.value.value ?? 0;
    if (accountId != null && mailboxName != null) {
      dashboardController.markAsReadMailbox(
        accountId,
        mailboxId,
        mailboxName,
        countEmailsUnread.toInt()
      );

      onCallbackAction?.call(context);
    }
  }
}