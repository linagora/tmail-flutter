import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension MoveEmailsToMailboxExtension on MailboxDashBoardController {
  void handleMoveEmailsToMailbox({
    required Map<MailboxId,List<EmailId>> originalMailboxIdsWithEmailIds,
    required MailboxId destinationMailboxId,
  }) {
    if (destinationMailboxId == selectedMailbox.value?.id) return;

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
    final currentEmailsToBeMoved = currentEmails
      .where((email) => movedEmailIds.contains(email.id))
      .toList();
    if (currentEmailsToBeMoved.isNotEmpty) {
      currentEmails.removeWhere(currentEmailsToBeMoved.contains);
      updateEmailList(currentEmails);
    }
    final currentMailbox = selectedMailbox.value;
    final currentTotalEmails = currentMailbox?.totalEmails;
    if (currentMailbox != null && currentTotalEmails != null) {
      int newTotalEmails = currentTotalEmails.value.value.toInt() - movedEmailIds.length;
      if (newTotalEmails < 0) newTotalEmails = 0;
      selectedMailbox.value = currentMailbox.copyWith(
        totalEmails: TotalEmails(UnsignedInt(newTotalEmails)),
      );
    }
  }
}