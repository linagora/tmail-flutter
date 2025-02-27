
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/destination_picker/presentation/model/destination_picker_arguments.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/mailbox_exception.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/spam_report_exception.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/handle_email_action_type_when_select_all_active_and_mailbox_opened_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_email_searched_to_folder_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/dialog_router.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleEmailActionTypeWhenSelectAllActiveAndSearchActiveExtension on MailboxDashBoardController {

  void handleActionTypeWhenSelectAllActiveAndSearchActive({
    required AppLocalizations appLocalizations,
    required EmailActionType actionType,
    PresentationMailbox? destinationMailbox,
  }) {
    final accountId = this.accountId.value;
    final session = sessionCurrent;
    if (session == null || accountId == null) {
      logError('MailboxDashBoardController::handleActionTypeWhenSelectAllActiveAndSearchActive: SESSION & ACCOUNT_ID is null');
      return;
    }

    final searchEmailFilter = searchController.searchEmailFilter.value;
    final filterOption = filterMessageOption.value;

    switch(actionType) {
      case EmailActionType.markAllAsRead:
        markAllSearchAsRead(
          session,
          accountId,
          searchEmailFilter,
          moreFilterCondition: filterOption.getFilterCondition(),
        );
        break;
      case EmailActionType.markAllAsUnread:
        markAllSearchAsUnread(
          session,
          accountId,
          searchEmailFilter,
          moreFilterCondition: filterOption.getFilterCondition(),
        );
        break;
      case EmailActionType.markAllAsStarred:
        markAllSearchAsStarred(
          session,
          accountId,
          searchEmailFilter,
          moreFilterCondition: filterOption.getFilterCondition(),
        );
        break;
      case EmailActionType.moveAll:
        moveAllEmailSearchedToFolder(
          appLocalizations,
          session,
          accountId,
          searchEmailFilter,
          moreFilterCondition: filterOption.getFilterCondition(),

        );
        break;
      case EmailActionType.moveAllToTrash:
        moveAllEmailSearchedToTrash(
          appLocalizations,
          session,
          accountId,
          searchEmailFilter,
          moreFilterCondition: filterOption.getFilterCondition(),
          destinationMailbox: destinationMailbox,
        );
        break;
      case EmailActionType.markAllAsSpam:
        markAllEmailSearchedAsSpam(
          appLocalizations,
          session,
          accountId,
          searchEmailFilter,
          moreFilterCondition: filterOption.getFilterCondition(),
          destinationMailbox: destinationMailbox,
        );
        break;
      default:
        break;
    }
  }

  void markAllSearchAsRead(
    Session session,
    AccountId accountId,
    SearchEmailFilter searchEmailFilter,
    {EmailFilterCondition? moreFilterCondition}
  ) {
    consumeState(markAllSearchAsReadInteractor.execute(
      session,
      accountId,
      searchEmailFilter,
      moreFilterCondition: moreFilterCondition,
    ));
  }

  void markAllSearchAsUnread(
    Session session,
    AccountId accountId,
    SearchEmailFilter searchEmailFilter,
    {EmailFilterCondition? moreFilterCondition}
  ) {
    consumeState(markAllSearchAsUnreadInteractor.execute(
      session,
      accountId,
      searchEmailFilter,
      moreFilterCondition: moreFilterCondition,
    ));
  }

  void markAllSearchAsStarred(
    Session session,
    AccountId accountId,
    SearchEmailFilter searchEmailFilter,
    {EmailFilterCondition? moreFilterCondition}
  ) {
    consumeState(markAllSearchAsStarredInteractor.execute(
      session,
      accountId,
      searchEmailFilter,
      moreFilterCondition: moreFilterCondition,
    ));
  }

  Future<void> moveAllEmailSearchedToFolder(
    AppLocalizations appLocalizations,
    Session session,
    AccountId accountId,
    SearchEmailFilter searchEmailFilter,
    {
      EmailFilterCondition? moreFilterCondition,
      PresentationMailbox? destinationMailbox,
    }
  ) async {
    if (destinationMailbox == null) {
      final arguments = DestinationPickerArguments(
        accountId,
        MailboxActions.moveEmail,
        session,
      );

      destinationMailbox = PlatformInfo.isWeb
        ? await DialogRouter.pushGeneralDialog(
            routeName: AppRoutes.destinationPicker,
            arguments: arguments,
          )
        : await push(AppRoutes.destinationPicker, arguments: arguments);
    }

    if (destinationMailbox is PresentationMailbox) {
      consumeState(moveAllEmailSearchedToFolderInteractor.execute(
        session,
        accountId,
        destinationMailbox.id,
        destinationMailbox.mailboxPath ?? destinationMailbox.getDisplayNameByAppLocalizations(appLocalizations),
        searchEmailFilter,
        isDestinationSpamMailbox: destinationMailbox.isSpam,
        moreFilterCondition: moreFilterCondition,
      ));
    }
  }

  Future<void> moveAllEmailSearchedToTrash(
    AppLocalizations appLocalizations,
    Session session,
    AccountId accountId,
    SearchEmailFilter searchEmailFilter,
    {
      EmailFilterCondition? moreFilterCondition,
      PresentationMailbox? destinationMailbox,
    }
  ) async {
    final trashMailboxId = destinationMailbox?.id
        ?? getMailboxIdByRole(PresentationMailbox.roleTrash);
    final trashMailboxPath = destinationMailbox?.getDisplayNameByAppLocalizations(appLocalizations)
        ?? mapMailboxById[trashMailboxId]?.getDisplayNameByAppLocalizations(appLocalizations)
        ?? '';

    if (trashMailboxId == null) {
      consumeState(Stream.value(Left(MoveAllEmailSearchedToFolderFailure(
        trashMailboxPath,
        NotFoundTrashMailboxException(),
      ))));
      return;
    }

    consumeState(moveAllEmailSearchedToFolderInteractor.execute(
      session,
      accountId,
      trashMailboxId,
      trashMailboxPath,
      searchEmailFilter,
      moreFilterCondition: moreFilterCondition,
    ));
  }

  Future<void> markAllEmailSearchedAsSpam(
    AppLocalizations appLocalizations,
    Session session,
    AccountId accountId,
    SearchEmailFilter searchEmailFilter,
    {
      EmailFilterCondition? moreFilterCondition,
      PresentationMailbox? destinationMailbox,
    }
  ) async {
    final spamMailboxId = destinationMailbox?.id ?? this.spamMailboxId;
    final spamMailboxPath = destinationMailbox?.getDisplayNameByAppLocalizations(appLocalizations)
        ?? mapMailboxById[spamMailboxId]?.getDisplayNameByAppLocalizations(appLocalizations)
        ?? '';

    if (spamMailboxId == null) {
      consumeState(Stream.value(Left(MoveAllEmailSearchedToFolderFailure(
        spamMailboxPath,
        NotFoundSpamMailboxException(),
      ))));
      return;
    }

    consumeState(moveAllEmailSearchedToFolderInteractor.execute(
      session,
      accountId,
      spamMailboxId,
      spamMailboxPath,
      searchEmailFilter,
      isDestinationSpamMailbox: true,
      moreFilterCondition: moreFilterCondition,
    ));
  }

  void dragEmailsToMailboxWhenSelectAllActiveAndSearchActive({
    required AppLocalizations appLocalizations,
    required PresentationMailbox destinationMailbox,
  }) {
    handleActionTypeWhenSelectAllActiveAndSearchActive(
      appLocalizations: appLocalizations,
      actionType: getTypeMoveAllActionForMailbox(destinationMailbox),
      destinationMailbox: destinationMailbox,
    );
  }
}