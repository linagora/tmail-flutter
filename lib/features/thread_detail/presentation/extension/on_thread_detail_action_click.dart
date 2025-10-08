import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/widget/popup_menu/popup_menu_item_action_widget.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/context_item_email_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/popup_menu_item_email_action.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_open_context_menu_extension.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/get_thread_detail_action_status.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension OnThreadDetailActionClick on ThreadDetailController {
  Future<void> onThreadDetailActionClick(EmailActionType threadDetailActionType) async {
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
      case EmailActionType.deletePermanently:
        mailboxDashBoardController.permanentDeleteMultipleEmailInThreadDetail(
          emailsInThreadDetailInfo,
          onConfirm: () => closeThreadDetailAction(currentContext),
        );
        break;
      case EmailActionType.moveToMailbox:
        final mailboxId = await _pickDestinationMailboxId();
        if (mailboxId == null) return;

        _moveToMailbox(mailboxId, threadDetailActionType);
        break;
      case EmailActionType.moveToTrash:
        final mailboxId = mailboxDashBoardController.getMailboxIdByRole(
          PresentationMailbox.roleTrash,
        );
        if (mailboxId == null) return;

        _moveToMailbox(mailboxId, threadDetailActionType);
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
      EmailActionType.moveToMailbox,
      if (!threadDetailIsArchived) EmailActionType.archiveMessage,
      threadDetailIsSpam ? EmailActionType.unSpam : EmailActionType.moveToSpam,
      threadDetailIsTrashed
          ? EmailActionType.deletePermanently
          : EmailActionType.moveToTrash,
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
                category: action.category,
              ),
            )
            .toList(),
        onContextMenuActionClick: (action) {
          popBack();
          onThreadDetailActionClick(action.action);
        },
        useGroupedActions: true,
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

  Future<MailboxId?> _pickDestinationMailboxId() async {
    if (session == null || accountId == null) return null;

    final threadMailboxIds = emailsInThreadDetailInfo
        .map((e) => e.mailboxIdContain)
        .nonNulls
        .toSet();
    MailboxId? mailboxIdSelected;
    if (threadMailboxIds.length == 1) { // All emails in the same mailbox
      mailboxIdSelected = threadMailboxIds.first;
    }

    final arguments = DestinationPickerArguments(
      accountId!,
      MailboxActions.moveEmail,
      session,
      mailboxIdSelected: mailboxIdSelected,
    );
    final destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(
            routeName: AppRoutes.destinationPicker,
            arguments: arguments,
          )
        : await push(AppRoutes.destinationPicker, arguments: arguments);
    if (destinationMailbox is! PresentationMailbox) return null;

    return destinationMailbox.id;
  }

  void onOpenAttachmentListAction() {
    mailboxDashBoardController.dispatchEmailUIAction(
      OpenAttachmentListAction(currentExpandedEmailId.value),
    );
  }
}