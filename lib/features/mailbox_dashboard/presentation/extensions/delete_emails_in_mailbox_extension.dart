import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension DeleteEmailsInMailboxExtension on MailboxDashBoardController {
  void handleDeleteEmailsInMailbox({
    required List<EmailId> emailIds,
    required MailboxId? affectedMailboxId,
  }) {
    if (selectedMailbox.value?.id != affectedMailboxId) {
      return;
    }

    emailsInCurrentMailbox.removeWhere((email) => emailIds.contains(email.id));
  }
}