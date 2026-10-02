import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

extension GetDraftMailboxIdForComposerExtension on ComposerController {
  MailboxId? getDraftMailboxIdForComposer() {
    final savedDraftMailboxId = composerArguments.value?.savedDraftMailboxId;
    final actionType = currentEmailActionType == EmailActionType.reopenComposerBrowser
        ? composerArguments.value?.savedActionType
        : currentEmailActionType;

    if (actionType == EmailActionType.editDraft && savedDraftMailboxId != null) {
      return savedDraftMailboxId;
    }

    final defaultDraftsMailbox = mailboxDashBoardController.mapDefaultMailboxIdByRole[
      PresentationMailbox.roleDrafts
    ];
    final lowercaseDraftsRole = PresentationMailbox.roleDrafts.value.toLowerCase();

    final identityEmail = identitySelected.value?.email;
    return mailboxDashBoardController.mapMailboxById.entries
      .firstWhereOrNull((entry) {
        if (identityEmail == null) return false;
        final mailbox = entry.value;
        return mailbox.emailTeamMailBoxes == identityEmail &&
          mailbox.name?.name.toLowerCase() == lowercaseDraftsRole;
      })
      ?.key ?? defaultDraftsMailbox;
  }
}