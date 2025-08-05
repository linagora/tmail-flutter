import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/email_selection_action_type.dart';

extension EmailSelectionActionTypeExtension on EmailSelectionActionType {
  EmailActionType? toEmailActionType() {
    switch (this) {
      case EmailSelectionActionType.markAsRead:
        return EmailActionType.markAsRead;
      case EmailSelectionActionType.markAsUnread:
        return EmailActionType.markAsUnread;
      case EmailSelectionActionType.markAsStarred:
        return EmailActionType.markAsStarred;
      case EmailSelectionActionType.unMarkAsStarred:
        return EmailActionType.unMarkAsStarred;
      case EmailSelectionActionType.moveToFolder:
        return EmailActionType.moveToMailbox;
      case EmailSelectionActionType.moveToTrash:
        return EmailActionType.moveToTrash;
      case EmailSelectionActionType.markAsSpam:
        return EmailActionType.moveToSpam;
      case EmailSelectionActionType.markAsNotSpam:
        return EmailActionType.unSpam;
      case EmailSelectionActionType.archiveMessage:
        return EmailActionType.archiveMessage;
      case EmailSelectionActionType.deletePermanently:
        return EmailActionType.deletePermanently;
      case EmailSelectionActionType.selectAll:
      case EmailSelectionActionType.moreAction:
        return null;
    }
  }
}
