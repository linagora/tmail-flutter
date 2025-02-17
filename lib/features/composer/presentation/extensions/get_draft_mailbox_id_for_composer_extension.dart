import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension GetDraftMailboxIdForComposerExtension on ComposerController {
  MailboxId? getDraftMailboxIdForComposer() {
    final defaultDraftsMailbox = mailboxDashBoardController.mapDefaultMailboxIdByRole[
      PresentationMailbox.roleDrafts
    ];
    final lowercaseDraftsRole = PresentationMailbox.roleDrafts.value.toLowerCase();

    return mailboxDashBoardController.mapMailboxById.entries
      .firstWhereOrNull((entry) {
        final mailbox = entry.value;
        return mailbox.emailTeamMailBoxes == identitySelected.value?.email &&
          mailbox.name?.name.toLowerCase() == lowercaseDraftsRole;
      })
      ?.key ?? defaultDraftsMailbox;
  }
}