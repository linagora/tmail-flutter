
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

enum MailListActionShortcutType {
  delete,
  newMessage,
  markAsRead,
  markAsUnread;

  EmailActionType? getEmailActionType({
    required List<PresentationEmail> selectedEmails,
    PresentationMailbox? selectedMailbox,
  }) {
    if (selectedEmails.isEmpty &&
        this != MailListActionShortcutType.newMessage) {
      return null;
    }

    switch(this) {
      case MailListActionShortcutType.delete:
        return selectedMailbox?.isDeletePermanentlyEnabled == true
            ? EmailActionType.deletePermanently
            : EmailActionType.moveToTrash;
      case MailListActionShortcutType.newMessage:
        return EmailActionType.compose;
      case MailListActionShortcutType.markAsRead:
        return selectedEmails.isAllEmailRead
            ? null
            : EmailActionType.markAsRead;
      case MailListActionShortcutType.markAsUnread:
        return selectedEmails.isAllEmailUnread
            ? null
            : EmailActionType.markAsUnread;
    }
  }
}