import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension GenerateMailboxesExtension on MailboxDashBoardController {
  Set<MailboxId>? get trashSpamMailboxIds {
    final spamId = spamMailboxId;
    final trashId = mapDefaultMailboxIdByRole[PresentationMailbox.roleTrash];

    if (spamId == null && trashId == null) {
      return null;
    }

    return {
      if (spamId != null) spamId,
      if (trashId != null) trashId,
    };
  }
}
