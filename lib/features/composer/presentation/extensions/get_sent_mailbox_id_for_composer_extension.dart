import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension GetSentMailboxIdForComposerExtension on ComposerController {
  MailboxId? getSentMailboxIdForComposer() {
    final defaultSentMailbox = mailboxDashBoardController.mapDefaultMailboxIdByRole[
      PresentationMailbox.roleSent
    ];
    final lowercaseSentRole = PresentationMailbox.roleSent.value.toLowerCase();

    return mailboxDashBoardController.mapMailboxById.entries
      .firstWhereOrNull((entry) {
        final mailbox = entry.value;
        return mailbox.emailTeamMailBoxes == identitySelected.value?.email &&
          mailbox.name?.name.toLowerCase() == lowercaseSentRole;
      })
      ?.key ?? defaultSentMailbox;
  }
}