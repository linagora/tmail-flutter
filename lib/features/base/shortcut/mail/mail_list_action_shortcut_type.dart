
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';

enum MailListActionShortcutType {
  delete,
  newMessage,
  markAsRead,
  markAsUnread;

  EmailActionType? getEmailActionType({
    required List<PresentationEmail> selectedEmails,
    required PresentationMailbox selectedMailbox,
  }) {
    if (selectedEmails.isEmpty &&
        this != MailListActionShortcutType.newMessage) {
      return null;
    }

    switch(this) {
      case MailListActionShortcutType.delete:
        return selectedMailbox.isDeletePermanentlyEnabled == true
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

  EmailActionType? getEmailActionTypeBySearch({
    required List<PresentationEmail> selectedEmails,
  }) {
    if (selectedEmails.isEmpty &&
        this != MailListActionShortcutType.newMessage) {
      return null;
    }

    switch(this) {
      case MailListActionShortcutType.delete:
        final isDeletePermanentlyEnabled =
            selectedEmails.every((e) => e.isDeletePermanentlyEnabled);
        return isDeletePermanentlyEnabled
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