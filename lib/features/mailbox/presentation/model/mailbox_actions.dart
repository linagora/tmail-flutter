
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/context_menu_item_action.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

enum MailboxActions {
  create,
  moveEmail,
  select,
  delete,
  rename,
  move,
  markAsRead,
  selectForRuleAction,
  openInNewTab,
  disableSpamReport,
  enableSpamReport,
  disableMailbox,
  enableMailbox,
  emptyTrash,
  emptySpam,
  newSubfolder,
  confirmMailSpam,
  recoverDeletedMessages,
  allowSubaddressing,
  disallowSubaddressing;
}

extension MailboxActionsExtension on MailboxActions {

  String getTitle(BuildContext context) {
    switch(this) {
      case MailboxActions.create:
        return AppLocalizations.of(context).selectParentFolder;
      case MailboxActions.moveEmail:
      case MailboxActions.move:
        return AppLocalizations.of(context).moveTo;
      case MailboxActions.select:
      case MailboxActions.selectForRuleAction:
        return AppLocalizations.of(context).selectFolder;
      default:
        return '';
    }
  }

  String getTitleContextMenu(BuildContext context) {
    switch(this) {
      case MailboxActions.openInNewTab:
        return AppLocalizations.of(context).openInNewTab;
      case MailboxActions.newSubfolder:
        return AppLocalizations.of(context).newSubfolder;
      case MailboxActions.disableSpamReport:
        return AppLocalizations.of(context).disableSpamReport;
      case MailboxActions.enableSpamReport:
        return AppLocalizations.of(context).enableSpamReport;
      case MailboxActions.markAsRead:
        return AppLocalizations.of(context).mark_as_read;
      case MailboxActions.move:
        return AppLocalizations.of(context).moveFolder;
      case MailboxActions.rename:
        return AppLocalizations.of(context).renameFolder;
      case MailboxActions.delete:
        return AppLocalizations.of(context).deleteFolder;
      case MailboxActions.disableMailbox:
        return AppLocalizations.of(context).hideFolder;
      case MailboxActions.enableMailbox:
        return AppLocalizations.of(context).showFolder;
      case MailboxActions.emptyTrash:
        return AppLocalizations.of(context).emptyTrash;
      case MailboxActions.emptySpam:
        return AppLocalizations.of(context).deleteAllSpamEmails;
      case MailboxActions.confirmMailSpam:
        return AppLocalizations.of(context).confirmAllEmailHereAreSpam;
      case MailboxActions.recoverDeletedMessages:
        return AppLocalizations.of(context).recoverDeletedMessages;
      case MailboxActions.allowSubaddressing:
        return AppLocalizations.of(context).allowSubaddressing;
      case MailboxActions.disallowSubaddressing:
        return AppLocalizations.of(context).disallowSubaddressing;
      default:
        return '';
    }
  }

  String getContextMenuIcon(ImagePaths imagePaths) {
    switch(this) {
      case MailboxActions.openInNewTab:
        return imagePaths.icOpenInNewTab;
      case MailboxActions.newSubfolder:
        return imagePaths.icAddNewFolder;
      case MailboxActions.disableSpamReport:
        return imagePaths.icSpamReportDisable;
      case MailboxActions.enableSpamReport:
        return imagePaths.icSpamReportEnable;
      case MailboxActions.markAsRead:
        return imagePaths.icMarkAsRead;
      case MailboxActions.move:
        return imagePaths.icMoveMailbox;
      case MailboxActions.rename:
        return imagePaths.icRenameMailbox;
      case MailboxActions.delete:
        return imagePaths.icDeleteMailbox;
      case MailboxActions.disableMailbox:
        return imagePaths.icHideMailbox;
      case MailboxActions.enableMailbox:
        return imagePaths.icShowMailbox;
      case MailboxActions.emptyTrash:
        return imagePaths.icMailboxTrash;
      case MailboxActions.emptySpam:
        return imagePaths.icMailboxTrash;
      case MailboxActions.confirmMailSpam:
        return imagePaths.icMarkAsRead;
      case MailboxActions.recoverDeletedMessages:
        return imagePaths.icRecoverDeletedMessages;
      case MailboxActions.allowSubaddressing:
        return imagePaths.icSubaddressingAllow;
      case MailboxActions.disallowSubaddressing:
        return imagePaths.icSubaddressingDisallow;
      default:
        return '';
    }
  }

  Color getColorContextMenuTitle() {
    switch(this) {
      case MailboxActions.delete:
        return AppColor.colorActionDeleteConfirmDialog;
      default:
        return Colors.black;
    }
  }

  Color getColorContextMenuIcon() {
    switch(this) {
      case MailboxActions.delete:
        return AppColor.colorActionDeleteConfirmDialog;
      default:
        return AppColor.primaryColor;
    }
  }

  bool canSearch() {
    switch(this) {
      case MailboxActions.create:
      case MailboxActions.moveEmail:
      case MailboxActions.move:
      case MailboxActions.select:
      case MailboxActions.selectForRuleAction:
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
      case MailboxActions.selectForRuleAction:
        return false;
      default:
        return true;
    }
  }

  ContextMenuItemState getContextMenuItemState(PresentationMailbox mailbox) {
    switch(this) {
      case MailboxActions.openInNewTab:
      case MailboxActions.newSubfolder:
      case MailboxActions.disableSpamReport:
      case MailboxActions.enableSpamReport:
      case MailboxActions.enableMailbox:
      case MailboxActions.disableMailbox:
      case MailboxActions.move:
      case MailboxActions.rename:
      case MailboxActions.delete:
      case MailboxActions.emptyTrash:
      case MailboxActions.emptySpam:
      case MailboxActions.confirmMailSpam:
      case MailboxActions.recoverDeletedMessages:
      case MailboxActions.allowSubaddressing:
      case MailboxActions.disallowSubaddressing:
        return ContextMenuItemState.activated;
      case MailboxActions.markAsRead:
        return mailbox.countUnReadEmailsAsString.isNotEmpty
          ? ContextMenuItemState.activated
          : ContextMenuItemState.deactivated;
      default:
        return ContextMenuItemState.deactivated;
    }
  }
}