import 'package:flutter/material.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/list_presentation_email_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/presentation/model/context_item_email_action.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/email_selection_action_type_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/extensions/list_email_selection_action_type_extension.dart';
import 'package:tmail_ui_user/features/thread/presentation/model/email_selection_action_type.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandlePressEmailSelectionActionExtension on ThreadController {
  void handlePressEmailSelectionAction(
    BuildContext context,
    EmailSelectionActionType type,
    List<PresentationEmail> emails,
    PresentationMailbox? selectedMailbox,
  ) {
    final emailActionType = type.toEmailActionType();
    if (emailActionType != null) {
      pressEmailSelectionAction(emailActionType, emails);
    } else if (type == EmailSelectionActionType.moreAction) {
      _showMoreActionMenu(context, emails, selectedMailbox);
    } else if (type == EmailSelectionActionType.selectAll) {
      _showSelectAllEmails();
    }
  }

  List<EmailSelectionActionType> _createEmailSelectionActionTypes(
    List<PresentationEmail> emails,
    PresentationMailbox? selectedMailbox,
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
      if (selectedMailbox?.isDeletePermanentlyEnabled != true)
        EmailSelectionActionType.moveToTrash,
      if (selectedMailbox?.isSpam == true)
        EmailSelectionActionType.markAsNotSpam
      else
        EmailSelectionActionType.markAsSpam,
      if (selectedMailbox?.isArchive != true)
        EmailSelectionActionType.archiveMessage,
      if (selectedMailbox?.isDeletePermanentlyEnabled == true)
        EmailSelectionActionType.deletePermanently,
    ];
  }

  Future<void> _showMoreActionMenu(
    BuildContext context,
    List<PresentationEmail> emails,
    PresentationMailbox? selectedMailbox,
  ) async {
    final emailActions = _createEmailSelectionActionTypes(
      emails,
      selectedMailbox,
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
        pressEmailSelectionAction(menuAction.action, emails);
      },
      useGroupedActions: true,
    );
  }

  void _showSelectAllEmails() {
    if (mailboxDashBoardController.emailsInCurrentMailbox.isAnySelectionInActive) {
      setSelectAllEmailAction();
    }
  }
}
