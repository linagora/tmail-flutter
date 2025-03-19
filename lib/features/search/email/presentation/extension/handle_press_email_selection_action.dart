import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/model/context_item_email_action.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/email_selection_action_type_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/list_email_selection_action_type_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/email_selection_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandlePressEmailSelectionActionExtension on SearchEmailController {
  void handlePressEmailSelectionAction(
    BuildContext context,
    EmailSelectionActionType type,
    List<PresentationEmail> emails,
    Map<MailboxId, PresentationMailbox> mapMailboxById,
  ) {
    final emailActionType = type.toEmailActionType();
    if (emailActionType != null) {
      handleSelectionEmailAction(emailActionType, emails);
    } else if (type == EmailSelectionActionType.moreAction) {
      _showMoreActionMenu(context, emails, mapMailboxById);
    } else if (type == EmailSelectionActionType.selectAll) {
      _showSelectAllEmails();
    }
  }

  List<EmailSelectionActionType> _createEmailSelectionActionTypes(
    List<PresentationEmail> emails,
    Map<MailboxId, PresentationMailbox> mapMailboxById,
  ) {
    return <EmailSelectionActionType>[
      if (emails.isAllEmailRead)
        EmailSelectionActionType.markAsUnread
      else
        EmailSelectionActionType.markAsRead,
      if (emails.isAllEmailStarred)
        EmailSelectionActionType.unMarkAsStarred
      else
        EmailSelectionActionType.markAsStarred,
      EmailSelectionActionType.moveToFolder,
      if (emails.isDeletePermanentlyDisabled(mapMailboxById))
        EmailSelectionActionType.moveToTrash,
      if (emails.isMarkAsSpamEnabled(mapMailboxById))
        EmailSelectionActionType.markAsSpam
      else
        EmailSelectionActionType.markAsNotSpam,
      if (emails.isArchiveMessageEnabled(mapMailboxById))
        EmailSelectionActionType.archiveMessage,
      if (!emails.isDeletePermanentlyDisabled(mapMailboxById))
        EmailSelectionActionType.deletePermanently,
    ];
  }

  Future<void> _showMoreActionMenu(
    BuildContext context,
    List<PresentationEmail> emails,
    Map<MailboxId, PresentationMailbox> mapMailboxById,
  ) async {
    final emailActions = _createEmailSelectionActionTypes(
      emails,
      mapMailboxById,
    ).emailActionTypes;

    final contextMenuActions = emailActions
        .map((action) => ContextItemEmailAction(
              action,
              AppLocalizations.of(context),
              imagePaths,
              category: action.category,
              key: '${action.name}_action',
            ))
        .toList();

    return openBottomSheetContextMenuAction(
      context: context,
      itemActions: contextMenuActions,
      onContextMenuActionClick: (menuAction) {
        popBack();
        handleSelectionEmailAction(menuAction.action, emails);
      },
      useGroupedActions: true,
    );
  }

  void _showSelectAllEmails() {
    if (listResultSearch.isAnySelectionInActive) {
      setSelectAllEmailAction();
    }
  }
}
