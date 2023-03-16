
import 'package:flutter/material.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

mixin MailboxActionHandlerMixin {

  void openMailboxInNewTabAction(PresentationMailbox mailbox) {
    AppUtils.launchLink(mailbox.mailboxRouteWeb.toString());
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