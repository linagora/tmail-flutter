
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/mailbox_exception.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/spam_report_exception.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_selection_all_emails_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleEmailActionTypeWhenSelectAllActiveAndMailboxOpenedExtension on MailboxDashBoardController {

  void handleActionTypeWhenSelectAllActiveAndMailboxOpened({
    required AppLocalizations appLocalizations,
    required PresentationMailbox selectedMailbox,
    required EmailActionType actionType,
    PresentationMailbox? destinationMailbox,
  }) {
    final accountId = this.accountId.value;
    final session = sessionCurrent;
    if (session == null || accountId == null) {
      logError('MailboxDashBoardController::handleActionTypeWhenSelectAllActiveAndMailboxOpened: SESSION & ACCOUNT_ID is null');
      return;
    }

    switch(actionType) {
      case EmailActionType.markAllAsRead:
        markAsReadMailbox(
          session,
          accountId,
          selectedMailbox.mailboxId!,
          selectedMailbox.getDisplayNameByAppLocalizations(appLocalizations),
          selectedMailbox.countUnreadEmails,
        );
        break;
      case EmailActionType.markAllAsUnread:
        markAllAsUnreadSelectionAllEmails(
          session,
          accountId,
          selectedMailbox.mailboxId!,
          selectedMailbox.getDisplayNameByAppLocalizations(appLocalizations),
          selectedMailbox.countReadEmails,
        );
        break;
      case EmailActionType.moveAll:
        moveAllSelectionAllEmails(
          appLocalizations,
          session,
          accountId,
          selectedMailbox,
          destinationMailbox: destinationMailbox,
        );
        break;
      case EmailActionType.moveAllToTrash:
        moveAllToTrashSelectionAllEmails(
          appLocalizations,
          session,
          accountId,
          selectedMailbox,
          trashMailbox: destinationMailbox,
        );
        break;
      case EmailActionType.deleteAllPermanently:
        deleteAllPermanentlyEmails(
          session,
          accountId,
          selectedMailbox,
        );
        break;
      case EmailActionType.markAllAsStarred:
        markAllAsStarredSelectionAllEmails(
          session,
          accountId,
          selectedMailbox.mailboxId!,
          selectedMailbox.getDisplayNameByAppLocalizations(appLocalizations),
          selectedMailbox.countTotalEmails,
        );
        break;
      case EmailActionType.markAllAsSpam:
        maskAllAsSpamSelectionAllEmails(
          appLocalizations,
          session,
          accountId,
          selectedMailbox,
          spamMailbox: destinationMailbox,
        );
        break;
      case EmailActionType.allUnSpam:
        allUnSpamSelectionAllEmails(
          appLocalizations,
          session,
          accountId,
          selectedMailbox,
        );
        break;
      default:
        break;
    }
  }

  void markAllAsUnreadSelectionAllEmails(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    String mailboxDisplayName,
    int totalEmailsRead,
  ) {
    consumeState(markAllAsUnreadSelectionAllEmailsInteractor.execute(
      session,
      accountId,
      mailboxId,
      mailboxDisplayName,
      totalEmailsRead,
      viewStateMailboxActionStreamController,
    ));
  }

  Future<void> moveAllSelectionAllEmails(
    AppLocalizations appLocalizations,
    Session session,
    AccountId accountId,
    PresentationMailbox currentMailbox,
    {
      PresentationMailbox? destinationMailbox,
    }
  ) async {
    if (destinationMailbox == null) {
      final arguments = DestinationPickerArguments(
        accountId,
        MailboxActions.moveEmail,
        session,
        mailboxIdSelected: currentMailbox.id,
      );

      destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(
            routeName: AppRoutes.destinationPicker,
            arguments: arguments,
          )
        : await push(AppRoutes.destinationPicker, arguments: arguments);
    }

    if (destinationMailbox is PresentationMailbox) {
      consumeState(moveAllSelectionAllEmailsInteractor.execute(
        session,
        accountId,
        currentMailbox.id,
        destinationMailbox.id,
        destinationMailbox.mailboxPath ?? destinationMailbox.getDisplayNameByAppLocalizations(appLocalizations),
        currentMailbox.countTotalEmails,
        viewStateMailboxActionStreamController,
        isDestinationSpamMailbox: destinationMailbox.isSpam,
      ));
    }
  }

  Future<void> moveAllToTrashSelectionAllEmails(
    AppLocalizations appLocalizations,
    Session session,
    AccountId accountId,
    PresentationMailbox currentMailbox,
    {
      PresentationMailbox? trashMailbox,
    }
  ) async {
    final trashMailboxId = trashMailbox?.id
        ?? getMailboxIdByRole(PresentationMailbox.roleTrash);
    final trashMailboxPath = trashMailbox?.getDisplayNameByAppLocalizations(appLocalizations)
        ?? mapMailboxById[trashMailboxId]?.getDisplayNameByAppLocalizations(appLocalizations)
        ?? '';

    if (trashMailboxId == null) {
      consumeState(Stream.value(Left(MoveAllSelectionAllEmailsFailure(
        destinationPath: trashMailboxPath,
        exception: NotFoundTrashMailboxException(),
      ))));
      return;
    }

    consumeState(moveAllSelectionAllEmailsInteractor.execute(
      session,
      accountId,
      currentMailbox.id,
      trashMailboxId,
      trashMailboxPath,
      currentMailbox.countTotalEmails,
      viewStateMailboxActionStreamController,
    ));
  }

  Future<void> deleteAllPermanentlyEmails(
    Session session,
    AccountId accountId,
    PresentationMailbox currentMailbox,
  ) async {
    consumeState(deleteAllPermanentlyEmailsInteractor.execute(
      session,
      accountId,
      currentMailbox.id,
      currentMailbox.countTotalEmails,
      viewStateMailboxActionStreamController,
    ));
  }

  void markAllAsStarredSelectionAllEmails(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    String mailboxDisplayName,
    int totalEmails,
  ) {
    consumeState(markAllAsStarredSelectionAllEmailsInteractor.execute(
      session,
      accountId,
      mailboxId,
      mailboxDisplayName,
      totalEmails,
      viewStateMailboxActionStreamController,
    ));
  }

  Future<void> maskAllAsSpamSelectionAllEmails(
    AppLocalizations appLocalizations,
    Session session,
    AccountId accountId,
    PresentationMailbox currentMailbox,
    {
      PresentationMailbox? spamMailbox,
    }
  ) async {
    final spamMailboxId = spamMailbox?.id ?? this.spamMailboxId;
    final spamMailboxPath = spamMailbox?.getDisplayNameByAppLocalizations(appLocalizations)
        ?? mapMailboxById[spamMailboxId]?.getDisplayNameByAppLocalizations(appLocalizations)
        ?? '';

    if (spamMailboxId == null) {
      consumeState(Stream.value(Left(MoveAllSelectionAllEmailsFailure(
        destinationPath: spamMailboxPath,
        exception: NotFoundSpamMailboxException(),
      ))));
      return;
    }

    consumeState(moveAllSelectionAllEmailsInteractor.execute(
      session,
      accountId,
      currentMailbox.id,
      spamMailboxId,
      spamMailboxPath,
      currentMailbox.countTotalEmails,
      viewStateMailboxActionStreamController,
    ));
  }

  Future<void> allUnSpamSelectionAllEmails(
    AppLocalizations appLocalizations,
    Session session,
    AccountId accountId,
    PresentationMailbox currentMailbox,
  ) async {
    final inboxMailboxId = getMailboxIdByRole(PresentationMailbox.roleInbox);
    final inboxMailboxPath = mapMailboxById[inboxMailboxId]
        ?.getDisplayNameByAppLocalizations(appLocalizations) ?? '';

    if (inboxMailboxId == null) {
      consumeState(Stream.value(Left(MoveAllSelectionAllEmailsFailure(
        destinationPath: inboxMailboxPath,
        exception: NotFoundInboxMailboxException(),
      ))));
      return;
    }

    consumeState(moveAllSelectionAllEmailsInteractor.execute(
      session,
      accountId,
      currentMailbox.id,
      inboxMailboxId,
      inboxMailboxPath,
      currentMailbox.countTotalEmails,
      viewStateMailboxActionStreamController,
    ));
  }

  void dragEmailsToMailboxWhenSelectAllActiveAndMailboxOpened({
    required AppLocalizations appLocalizations,
    required PresentationMailbox selectedMailbox,
    required PresentationMailbox destinationMailbox,
  }) {
    handleActionTypeWhenSelectAllActiveAndMailboxOpened(
      appLocalizations: appLocalizations,
      selectedMailbox: selectedMailbox,
      actionType: getTypeMoveAllActionForMailbox(destinationMailbox),
      destinationMailbox: destinationMailbox,
    );
  }

  EmailActionType getTypeMoveAllActionForMailbox(PresentationMailbox presentationMailbox) {
    if (presentationMailbox.isTrash) {
      return EmailActionType.moveAllToTrash;
    } else if (presentationMailbox.isSpam) {
      return EmailActionType.markAllAsSpam;
    } else {
      return EmailActionType.moveAll;
    }
  }
}