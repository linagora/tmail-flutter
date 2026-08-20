import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/apply_to_visible_email_list_extension.dart';

extension DeleteEmailsInMailboxExtension on MailboxDashBoardController {
  void handleDeleteEmailsInMailbox({
    required List<EmailId> emailIds,
    required MailboxId? affectedMailboxId,
  }) {
    if (emailIds.isEmpty) return;

    final deletedEmailIds = emailIds.toSet();
    applyToVisibleEmailList(
      (emails) => emails
          .where((email) => !deletedEmailIds.contains(email.id))
          .toList(),
      shouldApplyToMailboxList: () =>
          selectedMailbox.value?.id == affectedMailboxId,
    );
  }

  void handleClearAllEmailsInMailbox(MailboxId mailboxId) {
    applyToVisibleEmailList(
      (emails) => emails
          .where(
            (email) =>
                email.mailboxIds?.containsKey(mailboxId) != true &&
                email.mailboxContain?.id != mailboxId,
          )
          .toList(),
      shouldApplyToMailboxList: () => selectedMailbox.value?.id == mailboxId,
    );
  }
}
