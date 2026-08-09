import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/model/popup_menu_item_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/context_item_mailbox_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/popup_menu_item_mailbox_action.dart';

mixin MailboxWidgetMixin {

  MailboxActions _mailboxActionForSpam(bool spamReportEnabled) {
    return spamReportEnabled
      ? MailboxActions.disableSpamReport
      : MailboxActions.enableSpamReport;
  }

  List<MailboxActions> _listActionForDefaultMailbox(
    PresentationMailbox mailbox,
    bool spamReportEnabled,
    bool deletedMessageVaultSupported
  ) {
    if (mailbox.isVirtualFolder) {
      return [
        if (PlatformInfo.isWeb)
          MailboxActions.openInNewTab,
      ];
    }

    return [
      if (PlatformInfo.isWeb)
        MailboxActions.openInNewTab,
      if (!mailbox.isRecovered)
        MailboxActions.newSubfolder,
      MailboxActions.createFilter,
      if (mailbox.isTrash)
        ...[
          MailboxActions.moveFolderContent,
          MailboxActions.emptyTrash,
          if (deletedMessageVaultSupported)
            MailboxActions.recoverDeletedMessages,
        ]
      else if (mailbox.isSpam)
        ...[
          MailboxActions.moveFolderContent,
          _mailboxActionForSpam(spamReportEnabled),
          MailboxActions.confirmMailSpam,
          MailboxActions.emptySpam
        ]
      else if (mailbox.countUnReadEmailsAsString.isNotEmpty)
        ...[
          MailboxActions.markAsRead,
          MailboxActions.moveFolderContent,
        ]
    ];
  }

  List<MailboxActions> _listActionForPersonalMailbox(PresentationMailbox mailbox, bool subaddressingSupported) {
    return [
      if (PlatformInfo.isWeb && mailbox.isSubscribedMailbox)
        MailboxActions.openInNewTab,
      MailboxActions.newSubfolder,
      MailboxActions.createFilter,
      if (mailbox.countUnReadEmailsAsString.isNotEmpty)
        MailboxActions.markAsRead,
      MailboxActions.move,
      MailboxActions.moveFolderContent,
      MailboxActions.rename,
      if (subaddressingSupported) ...[
        if (mailbox.isSubaddressingAllowed)
          MailboxActions.disallowSubaddressing
        else
          MailboxActions.allowSubaddressing,
        if (mailbox.isSubaddressingAllowed)
          MailboxActions.copySubaddress,
      ],
      if (mailbox.isSubscribedMailbox)
        MailboxActions.disableMailbox
      else
        MailboxActions.enableMailbox,
      MailboxActions.delete
    ];
  }

  List<MailboxActions> _listActionForTeamMailbox(PresentationMailbox mailbox) {
    return [
      if (PlatformInfo.isWeb && mailbox.isSubscribedMailbox)
        MailboxActions.openInNewTab,
      if (mailbox.myRights?.mayCreateChild == true)
        MailboxActions.newSubfolder,
      if (mailbox.countUnReadEmailsAsString.isNotEmpty &&
          mailbox.myRights?.mayReadItems != false)
        MailboxActions.markAsRead,
      if (mailbox.myRights?.mayRename == true)
        MailboxActions.rename,
      if (mailbox.isTeamMailboxes || mailbox.isSharedAccount)
        if (mailbox.isSubscribedMailbox)
          MailboxActions.disableMailbox
        else
          MailboxActions.enableMailbox,
      if (mailbox.isTrash && mailbox.myRights?.mayRemoveItems == true)
        MailboxActions.emptyTrash,
      if (mailbox.myRights?.mayDelete == true)
        MailboxActions.delete,
    ];
  }

  List<MailboxActions> _listActionForAllMailboxType(
    PresentationMailbox mailbox,
    bool spamReportEnabled,
    bool deletedMessageVaultSupported,
    bool isSubAddressingSupported,
  ) {
    // Every mailbox in another user's account is myRights-gated like a team
    // mailbox, regardless of whether it carries a role (a shared Inbox would
    // otherwise fall into the un-gated default-mailbox action list). Move and
    // createFilter are absent here: cross-account move is unsupported and
    // filters are a primary-account concept.
    if (mailbox.isSharedAccount) {
      return _listActionForTeamMailbox(mailbox);
    }

    if (mailbox.isDefault) {
      return _listActionForDefaultMailbox(
        mailbox,
        spamReportEnabled,
        deletedMessageVaultSupported,
      );
    } else if (mailbox.isPersonal) {
      return _listActionForPersonalMailbox(mailbox, isSubAddressingSupported);
    } else {
      return _listActionForTeamMailbox(mailbox);
    }
  }

  List<ContextMenuItemMailboxAction> listContextMenuItemAction(
    PresentationMailbox mailbox,
    bool spamReportEnabled,
    bool deletedMessageVaultSupported,
    bool isSubAddressingSupported,
    ImagePaths imagePaths,
    AppLocalizations appLocalizations,
  ) {
    final mailboxActionsSupported = _listActionForAllMailboxType(
      mailbox,
      spamReportEnabled,
      deletedMessageVaultSupported,
      isSubAddressingSupported,
    );

    final listContextMenuItemAction = mailboxActionsSupported
      .map((action) => ContextMenuItemMailboxAction(
        action,
        appLocalizations,
        imagePaths
      ))
      .toList();

    return listContextMenuItemAction;
  }

  List<PopupMenuItemAction> getListPopupMenuItemAction(
    AppLocalizations appLocalizations,
    ImagePaths imagePaths,
    PresentationMailbox presentationMailbox,
    bool spamReportEnabled,
    bool deletedMessageVaultSupported,
    bool isSubAddressingSupported,
  ) {
    final mailboxActionsSupported = _listActionForAllMailboxType(
      presentationMailbox,
      spamReportEnabled,
      deletedMessageVaultSupported,
      isSubAddressingSupported,
    );

    final popupMenuActions = mailboxActionsSupported
      .map((action) => PopupMenuItemMailboxAction(
        action,
        appLocalizations,
        imagePaths,
      ))
      .toList();

    return popupMenuActions;
  }
}