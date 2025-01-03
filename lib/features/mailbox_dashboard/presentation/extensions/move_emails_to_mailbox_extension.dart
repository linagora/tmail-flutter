import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension MoveEmailsToMailboxExtension on MailboxDashBoardController {
  void handleMoveEmailsToMailbox({
    required Map<MailboxId,List<EmailId>> originalMailboxIdsWithEmailIds,
    required MailboxId destinationMailboxId,
    required MoveAction moveAction,
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
    final currentEmailsToBeMoved = currentEmails
      .where((email) => movedEmailIds.contains(email.id))
      .toList();
    if (currentEmailsToBeMoved.isNotEmpty && destinationMailboxId != selectedMailbox.value?.id) {
      emailsToBeUndo = currentEmailsToBeMoved;
      currentEmails.removeWhere(currentEmailsToBeMoved.contains);
      updateEmailList(currentEmails);
    } else if (moveAction == MoveAction.undo && destinationMailboxId == selectedMailbox.value?.id) {
      currentEmails.addAll(emailsToBeUndo);
      currentEmails.sort((a, b) => b.receivedAt?.value.compareTo(a.receivedAt?.value ?? DateTime.now()) ?? -1);
      updateEmailList(currentEmails);
    }
  }
}