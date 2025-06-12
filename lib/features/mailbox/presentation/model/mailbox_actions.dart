import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
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
  selectForRuleAction,
  openInNewTab,
  copySubaddress,
  disableSpamReport,
  enableSpamReport,
  disableMailbox,
  enableMailbox,
  emptyTrash,
  emptySpam,
  newSubfolder,
  createFilter,
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

  String getTitleContextMenu(AppLocalizations appLocalizations) {
    switch(this) {
      case MailboxActions.openInNewTab:
        return appLocalizations.openInNewTab;
      case MailboxActions.copySubaddress:
        return appLocalizations.copySubaddress;
      case MailboxActions.newSubfolder:
        return appLocalizations.newSubfolder;
      case MailboxActions.createFilter:
        return appLocalizations.createFilter;
      case MailboxActions.disableSpamReport:
        return appLocalizations.disableSpamReport;
      case MailboxActions.enableSpamReport:
        return appLocalizations.enableSpamReport;
      case MailboxActions.markAsRead:
        return appLocalizations.mark_as_read;
      case MailboxActions.move:
        return appLocalizations.moveFolder;
      case MailboxActions.rename:
        return appLocalizations.renameFolder;
      case MailboxActions.delete:
        return appLocalizations.deleteFolder;
      case MailboxActions.disableMailbox:
        return appLocalizations.hideFolder;
      case MailboxActions.enableMailbox:
        return appLocalizations.showFolder;
      case MailboxActions.emptyTrash:
        return appLocalizations.emptyTrash;
      case MailboxActions.emptySpam:
        return appLocalizations.deleteAllSpamEmails;
      case MailboxActions.confirmMailSpam:
        return appLocalizations.confirmAllEmailHereAreSpam;
      case MailboxActions.recoverDeletedMessages:
        return appLocalizations.recoverDeletedMessages;
      case MailboxActions.allowSubaddressing:
        return appLocalizations.allowSubaddressing;
      case MailboxActions.disallowSubaddressing:
        return appLocalizations.disallowSubaddressing;
      default:
        return '';
    }
  }

  String getContextMenuIcon(ImagePaths imagePaths) {
    switch(this) {
      case MailboxActions.openInNewTab:
        return imagePaths.icOpenInNewTab;
      case MailboxActions.copySubaddress:
        return imagePaths.icCopy;
      case MailboxActions.newSubfolder:
        return imagePaths.icAddNewFolder;
      case MailboxActions.createFilter:
        return imagePaths.icCreateFilter;
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

  Color getPopupMenuTitleColor() {
    switch(this) {
      case MailboxActions.delete:
        return AppColor.redFF3347;
      default:
        return Colors.black;
    }
  }

  Color getPopupMenuIconColor() {
    switch(this) {
      case MailboxActions.delete:
        return AppColor.redFF3347;
      default:
        return AppColor.steelGrayA540;
    }
  }

  Color getContextMenuIconColor() {
    switch (this) {
      case MailboxActions.delete:
        return AppColor.redFF3347;
      default:
        return AppColor.gray424244.withOpacity(0.72);
    }
  }

  Color getContextMenuTitleColor() {
    switch (this) {
      case MailboxActions.delete:
        return AppColor.redFF3347;
      default:
        return AppColor.gray424244.withOpacity(0.9);
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
}