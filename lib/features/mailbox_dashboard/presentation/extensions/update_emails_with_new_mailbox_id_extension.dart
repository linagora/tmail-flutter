import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/search_email_presentation_owner_extension.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

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

    if (isSearchEmailPresentationOwner) {
      appProviderContainer
          .read(searchEmailPresentationProvider.notifier)
          .updateResultSearches(updateEmails);
      return;
    }

    updateEmailList(updateEmails(List<PresentationEmail>.from(
      emailsInCurrentMailbox,
    )));
  }
}
