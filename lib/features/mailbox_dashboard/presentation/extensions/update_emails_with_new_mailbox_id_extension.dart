import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/apply_to_visible_email_list_extension.dart';

extension UpdateEmailsWithNewMailboxIdExtension on MailboxDashBoardController {
  void handleUpdateEmailsWithNewMailboxId({
    required Map<MailboxId,List<EmailId>> originalMailboxIdsWithEmailIds,
    required MailboxId destinationMailboxId,
  }) {
    final movedEmailIds = originalMailboxIdsWithEmailIds.entries.fold(
      <EmailId>{},
      (emailIds, entry) {
        emailIds.addAll(entry.value);
        return emailIds;
      },
    );
    if (movedEmailIds.isEmpty) return;

    List<PresentationEmail> updateEmails(List<PresentationEmail> emails) =>
        emails.map((email) {
          if (!movedEmailIds.contains(email.id)) return email;

          return email.copyWith(
            mailboxIds: {destinationMailboxId: true},
            mailboxContain: mapMailboxById[destinationMailboxId],
          );
        }).toList();

    applyToVisibleEmailList(updateEmails);
  }
}
