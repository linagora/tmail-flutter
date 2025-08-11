import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/model/context_item_email_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/popup_menu_item_email_action.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_open_context_menu_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_detail_action_status.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension OnThreadDetailActionClick on ThreadDetailController {
  void onThreadDetailActionClick(EmailActionType threadDetailActionType) {
    switch (threadDetailActionType) {
      case EmailActionType.markAsRead:
      case EmailActionType.markAsUnread:
        if (session == null || accountId == null) {
          consumeState(Stream.value(Left(MarkAsMultipleEmailReadFailure(
            threadDetailActionType == EmailActionType.markAsRead
                ? ReadActions.markAsRead
                : ReadActions.markAsUnread,
            NotFoundSessionException(),
          ))));
          return;
        }
        consumeState(markAsMultipleEmailReadInteractor.execute(
          session!,
          accountId!,
          emailsInThreadDetailInfo.map((e) => e.emailId).toList(),
          threadDetailActionType == EmailActionType.markAsRead
              ? ReadActions.markAsRead
              : ReadActions.markAsUnread,
          {},
        ));
        break;
      case EmailActionType.markAsStarred:
      case EmailActionType.unMarkAsStarred:
        if (session == null || accountId == null) {
          consumeState(Stream.value(Left(MarkAsStarMultipleEmailFailure(
            threadDetailActionType == EmailActionType.markAsStarred
                ? MarkStarAction.markStar
                : MarkStarAction.unMarkStar,
            NotFoundSessionException(),
          ))));
          return;
        }
        consumeState(markAsStarMultipleEmailInteractor.execute(
          session!,
          accountId!,
          emailsInThreadDetailInfo.map((e) => e.emailId).toList(),
          threadDetailActionType == EmailActionType.markAsStarred
              ? MarkStarAction.markStar
              : MarkStarAction.unMarkStar,
        ));
        break;
      case EmailActionType.archiveMessage:
        final mailboxId = mailboxDashBoardController.getMailboxIdByRole(
          PresentationMailbox.roleArchive,
        );
        if (mailboxId == null) return;

        _moveToMailbox(mailboxId, threadDetailActionType);
        break;
      case EmailActionType.moveToSpam:
        final mailboxId = mailboxDashBoardController.getMailboxIdByRole(
          PresentationMailbox.roleJunk,
        ) ?? mailboxDashBoardController.getMailboxIdByRole(
          PresentationMailbox.roleSpam,
        );
        if (mailboxId == null) return;

        _moveToMailbox(mailboxId, threadDetailActionType);
        break;
      case EmailActionType.unSpam:
        final mailboxId = mailboxDashBoardController.getMailboxIdByRole(
          PresentationMailbox.roleInbox,
        );
        if (mailboxId == null) return;

        _moveToMailbox(mailboxId, threadDetailActionType);
        break;
      default:
        break;
    }
  }

  void onThreadDetailMoreActionClick(RelativeRect? position) {
    if (currentContext == null) return;

    final moreActions = [
      threadDetailIsRead
          ? EmailActionType.markAsUnread
          : EmailActionType.markAsRead,
      threadDetailIsStarred
          ? EmailActionType.unMarkAsStarred
          : EmailActionType.markAsStarred,
      if (!threadDetailIsArchived) EmailActionType.archiveMessage,
      threadDetailIsSpam ? EmailActionType.unSpam : EmailActionType.moveToSpam,
    ];

    if (position == null) {
      mailboxDashBoardController.openBottomSheetContextMenu(
        context: currentContext!,
        itemActions: moreActions
            .map(
              (action) => ContextItemEmailAction(
                action,
                AppLocalizations.of(currentContext!),
                imagePaths,
              ),
            )
            .toList(),
        onContextMenuActionClick: (action) {
          popBack();
          onThreadDetailActionClick(action.action);
        },
      );
    } else {
      mailboxDashBoardController.openPopupMenu(
        currentContext!,
        position,
        moreActions.map((action) {
          return PopupMenuItem(
            key: Key('${action.name}_action'),
            padding: EdgeInsets.zero,
            child: PopupMenuItemActionWidget(
              menuAction: PopupMenuItemEmailAction(
                action,
                AppLocalizations.of(currentContext!),
                imagePaths,
              ),
              menuActionClick: (_) {
                popBack();
                onThreadDetailActionClick(action);
              },
            ),
          );
        }).toList(),
      );
    }
  }

  void _moveToMailbox(MailboxId mailboxId, EmailActionType emailActionType) {
    closeThreadDetailAction(currentContext);
    mailboxDashBoardController.moveMultipleEmailInThreadDetail(
      emailsInThreadDetailInfo,
      destinationMailboxId: mailboxId,
      emailActionType: emailActionType,
    );
  }
}