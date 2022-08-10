
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum MailboxActions {
  create,
  moveEmail,
  select,
  delete,
  rename,
  move,
  markAsRead,
  selectFromRuleFilter,
}

extension MailboxActionsExtension on MailboxActions {

  String getTitle(BuildContext context) {
    switch(this) {
      case MailboxActions.create:
        return AppLocalizations.of(context).mailbox_location;
      case MailboxActions.moveEmail:
      case MailboxActions.move:
        return AppLocalizations.of(context).moveTo;
      case MailboxActions.select:
      case MailboxActions.selectFromRuleFilter:
        return AppLocalizations.of(context).selectMailbox;
      default:
        return '';
    }
  }

  String getTitleContextMenu(BuildContext context) {
    switch(this) {
      case MailboxActions.markAsRead:
        return AppLocalizations.of(context).mark_as_read;
      case MailboxActions.move:
        return AppLocalizations.of(context).moveMailbox;
      case MailboxActions.rename:
        return AppLocalizations.of(context).rename_mailbox;
      case MailboxActions.delete:
        return AppLocalizations.of(context).deleteMailbox;
      default:
        return '';
    }
  }

  String getContextMenuIcon(ImagePaths imagePaths) {
    switch(this) {
      case MailboxActions.markAsRead:
        return imagePaths.icRead;
      case MailboxActions.move:
        return imagePaths.icMove;
      case MailboxActions.rename:
        return imagePaths.icRenameMailbox;
      case MailboxActions.delete:
        return imagePaths.icDelete;
      default:
        return '';
    }
  }

  Color getColorContextMenuIcon() {
    switch(this) {
      case MailboxActions.delete:
        return AppColor.colorActionDeleteConfirmDialog;
      default:
        return Colors.black;
    }
  }

  Color getBackgroundColor() {
    switch(this) {
      case MailboxActions.create:
        return AppColor.colorBgMailbox;
      default:
        return Colors.white;
    }
  }

  bool hasSearchActive() {
    switch(this) {
      case MailboxActions.moveEmail:
      case MailboxActions.move:
      case MailboxActions.select:
      case MailboxActions.selectFromRuleFilter:
        return true;
      default:
        return false;
    }
  }

  bool hasAllMailboxDefault() {
    switch(this) {
      case MailboxActions.create:
      case MailboxActions.move:
      case MailboxActions.select:
        return true;
      default:
        return false;
    }
  }

  bool canCollapseMailboxGroup() {
    switch(this) {
      case MailboxActions.moveEmail:
      case MailboxActions.move:
      case MailboxActions.select:
      case MailboxActions.selectFromRuleFilter:
        return false;
      default:
        return true;
    }
  }
}