import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/search_email_presentation_owner_extension.dart';
import 'package:tmail_ui_user/features/search/email/presentation/notifier/search_email_presentation_notifier.dart';
import 'package:tmail_ui_user/main/providers/app_provider_container.dart';

extension DeleteEmailsInMailboxExtension on MailboxDashBoardController {
  void handleDeleteEmailsInMailbox({
    required List<EmailId> emailIds,
    required MailboxId? affectedMailboxId,
  }) {
    if (emailIds.isEmpty) return;

    if (isSearchEmailPresentationOwner) {
      final deletedEmailIds = emailIds.toSet();
      appProviderContainer
          .read(searchEmailPresentationProvider.notifier)
          .updateResultSearches(
            (emails) => emails
                .where((email) => !deletedEmailIds.contains(email.id))
                .toList(),
          );
      return;
    }

    if (selectedMailbox.value?.id != affectedMailboxId) {
      return;
    }

    emailsInCurrentMailbox.removeWhere((email) => emailIds.contains(email.id));
  }

  void handleClearAllEmailsInMailbox(MailboxId mailboxId) {
    if (isSearchEmailPresentationOwner) {
      appProviderContainer
          .read(searchEmailPresentationProvider.notifier)
          .updateResultSearches(
            (emails) => emails
                .where(
                  (email) =>
                      email.mailboxIds?.containsKey(mailboxId) != true &&
                      email.mailboxContain?.id != mailboxId,
                )
                .toList(),
          );
      return;
    }

    if (selectedMailbox.value?.id != mailboxId) return;
    emailsInCurrentMailbox.clear();
  }
}
