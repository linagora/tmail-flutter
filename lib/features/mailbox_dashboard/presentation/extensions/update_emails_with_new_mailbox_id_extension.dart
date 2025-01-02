import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension UpdateEmailsWithNewMailboxIdExtension on MailboxDashBoardController {
  handleUpdateEmailsWithNewMailboxId({
    required Map<MailboxId,List<EmailId>> originalMailboxIdsWithEmailIds,
    required MailboxId destinationMailboxId,
  }) {
    final currentEmails = List<PresentationEmail>.from(
      emailsInCurrentMailbox,
    );
    final movedEmailIds = originalMailboxIdsWithEmailIds.entries.fold(
      <EmailId>{},
      (emailIds, entry) {
        emailIds.addAll(entry.value);
        return emailIds;
      },
    ).toList();
    for (var email in currentEmails) {
      if (!movedEmailIds.contains(email.id)) continue;

      email = email.copyWith(
        mailboxIds: {destinationMailboxId: true},
        mailboxContain: mapMailboxById[destinationMailboxId],
      );
    }
  }
}