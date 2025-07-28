
import 'package:model/email/email_action_type.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/presentation_email_extension.dart';

enum MailViewActionShortcutType {
  reply,
  replyAll,
  forward,
  delete,
  newMessage,
  markAsUnread;

  EmailActionType? getEmailActionType({
    required PresentationEmail currentEmail,
    required String ownerEmailAddress,
  }) {
    switch(this) {
      case MailViewActionShortcutType.reply:
        return EmailActionType.reply;
      case MailViewActionShortcutType.replyAll:
        if (currentEmail.isReplyAllEnabled(ownerEmailAddress)) {
          return EmailActionType.replyAll;
        } else {
          return null;
        }
      case MailViewActionShortcutType.forward:
        return EmailActionType.forward;
      case MailViewActionShortcutType.delete:
        return currentEmail.isDeletePermanentlyEnabled
          ? EmailActionType.deletePermanently
          : EmailActionType.moveToTrash;
      case MailViewActionShortcutType.newMessage:
        return EmailActionType.compose;
      case MailViewActionShortcutType.markAsUnread:
        return EmailActionType.markAsUnread;
    }
  }
}