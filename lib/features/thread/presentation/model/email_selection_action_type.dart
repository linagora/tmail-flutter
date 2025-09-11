import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum EmailSelectionActionType {
  selectAll,
  markAsRead,
  markAsUnread,
  markAsStarred,
  unMarkAsStarred,
  moveToFolder,
  moveToTrash,
  markAsSpam,
  markAsNotSpam,
  archiveMessage,
  deletePermanently,
  moreAction;

  String getTitle(AppLocalizations appLocalizations) {
    switch (this) {
      case EmailSelectionActionType.selectAll:
        return appLocalizations.select_all;
      case EmailSelectionActionType.markAsRead:
        return appLocalizations.mark_as_read;
      case EmailSelectionActionType.markAsUnread:
        return appLocalizations.mark_as_unread;
      case EmailSelectionActionType.markAsStarred:
        return appLocalizations.star;
      case EmailSelectionActionType.unMarkAsStarred:
        return appLocalizations.un_star;
      case EmailSelectionActionType.moveToFolder:
        return appLocalizations.move;
      case EmailSelectionActionType.moveToTrash:
        return appLocalizations.move_to_trash;
      case EmailSelectionActionType.markAsSpam:
        return appLocalizations.markAsSpam;
      case EmailSelectionActionType.markAsNotSpam:
        return appLocalizations.marked_as_not_spam;
      case EmailSelectionActionType.archiveMessage:
        return appLocalizations.archiveMessage;
      case EmailSelectionActionType.deletePermanently:
        return appLocalizations.delete_permanently;
      case EmailSelectionActionType.moreAction:
        return appLocalizations.more;
    }
  }

  String getIcon(ImagePaths imagePaths) {
    switch (this) {
      case EmailSelectionActionType.selectAll:
        return imagePaths.icCheckboxSelected;
      case EmailSelectionActionType.markAsRead:
        return imagePaths.icRead;
      case EmailSelectionActionType.markAsUnread:
        return imagePaths.icUnread;
      case EmailSelectionActionType.markAsStarred:
        return imagePaths.icStar;
      case EmailSelectionActionType.unMarkAsStarred:
        return imagePaths.icUnStar;
      case EmailSelectionActionType.moveToFolder:
        return imagePaths.icMoveMailbox;
      case EmailSelectionActionType.moveToTrash:
      case EmailSelectionActionType.deletePermanently:
        return imagePaths.icDeleteComposer;
      case EmailSelectionActionType.markAsSpam:
        return imagePaths.icSpam;
      case EmailSelectionActionType.markAsNotSpam:
        return imagePaths.icNotSpam;
      case EmailSelectionActionType.archiveMessage:
        return imagePaths.icMailboxArchived;
      case EmailSelectionActionType.moreAction:
        return imagePaths.icMoreVertical;
    }
  }

  Color getIconColor() {
    if (this == EmailSelectionActionType.deletePermanently) {
      return AppColor.redFF3347;
    } else {
      return AppColor.steelGrayA540;
    }
  }

  double getIconSize() => 20.0;
}
