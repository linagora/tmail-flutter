
import 'package:core/core.dart';
import 'package:flutter/material.dart';
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
  enableSpamReport
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
        return AppLocalizations.of(context).selectMailbox;
      default:
        return '';
    }
  }

  String getTitleContextMenu(BuildContext context) {
    switch(this) {
      case MailboxActions.openInNewTab:
        return AppLocalizations.of(context).openInNewTab;
      case MailboxActions.disableSpamReport:
        return AppLocalizations.of(context).disableSpamReport;
      case MailboxActions.enableSpamReport:
        return AppLocalizations.of(context).enableSpamReport;
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
      case MailboxActions.openInNewTab:
        return imagePaths.icOpenInNewTab;
      case MailboxActions.disableSpamReport:
        return imagePaths.icSpamReportDisable;
      case MailboxActions.enableSpamReport:
        return imagePaths.icSpamReportEnable;
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
      case MailboxActions.disableSpamReport:
      case MailboxActions.enableSpamReport:
        return AppColor.primaryColor;
      default:
        return Colors.black;
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
      case MailboxActions.disableSpamReport:
      case MailboxActions.enableSpamReport:
        return ContextMenuItemState.activated; 
      case MailboxActions.markAsRead:
        return mailbox.getCountUnReadEmails().isNotEmpty
            ? ContextMenuItemState.activated
            : ContextMenuItemState.deactivated;
      case MailboxActions.move:
      case MailboxActions.rename:
      case MailboxActions.delete:
        return mailbox.hasRole()
            ? ContextMenuItemState.deactivated
            : ContextMenuItemState.activated;
      default:
        return ContextMenuItemState.deactivated;
    }
  }
}