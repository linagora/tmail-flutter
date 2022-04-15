
import 'package:flutter/cupertino.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

extension EmailActionTypeExtension on EmailActionType {
  String getSubjectComposer(BuildContext context, String subject) {
    switch(this) {
      case EmailActionType.reply:
      case EmailActionType.replyAll:
        if (subject.toLowerCase().startsWith('re:')) {
          return subject;
        } else {
          return '${AppLocalizations.of(context).prefix_reply_email} $subject';
        }
      case EmailActionType.forward:
        if (subject.toLowerCase().startsWith('fwd:')) {
          return subject;
        } else {
          return '${AppLocalizations.of(context).prefix_forward_email} $subject';
        }
      case EmailActionType.edit:
        return subject;
      default:
        return '';
    }
  }

  String getToastMessageMoveToMailboxSuccess(BuildContext context, {String? destinationPath}) {
    switch(this) {
      case EmailActionType.moveToMailbox:
        return AppLocalizations.of(context).moved_to_mailbox(destinationPath ?? '');
      case EmailActionType.moveToTrash:
        return AppLocalizations.of(context).moved_to_trash;
      case EmailActionType.moveToSpam:
        return AppLocalizations.of(context).marked_as_spam;
      case EmailActionType.unSpam:
        return AppLocalizations.of(context).marked_as_not_spam;
      default:
        return '';
    }
  }
}