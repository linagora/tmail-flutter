import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_folder_content_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_folder_content_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_controller.dart';

extension HandleMoveFolderContentExtension on MailboxController {
  void performMoveFolderContent({
    required BuildContext context,
    required PresentationMailbox mailboxSelected,
  }) {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (accountId == null || session == null) {
      consumeState(
        Stream.value(
          Left(MoveFolderContentFailure(NotFoundAccountIdException())),
        ),
      );
      return;
    }

    moveFolderContentAction(
      context: context,
      accountId: accountId,
      session: session,
      mailboxSelected: mailboxSelected,
      onMoveFolderContentAction: (currentMailbox, destinationMailbox) {
        consumeState(mailboxActionReactor.moveFolderContent(
          session: session,
          accountId: accountId,
          moveRequest: MoveFolderContentRequest(
            moveAction: MoveAction.moving,
            mailboxId: currentMailbox.id,
            destinationMailboxId: destinationMailbox.id,
            destinationMailboxDisplayName:
            destinationMailbox.getDisplayName(context),
            markAsRead: destinationMailbox.isSpam,
            totalEmails: currentMailbox.countTotalEmails,
          ),
          onProgressController:
            mailboxDashBoardController.progressStateController,
        ));
      },
    );
  }

  void handleMoveFolderContentSuccess(MoveFolderContentSuccess success) {
    mailboxDashBoardController.syncViewStateMailboxActionProgress(
      newState: Right(UIState.idle),
    );
    final moveFolderRequest = success.request;

    if (moveFolderRequest.moveAction == MoveAction.moving) {
      toastManager.showMessageSuccessWithAction(
        success: success,
        onActionCallback: () {
          _undoMoveFolderContentAction(
            newMoveRequest: MoveFolderContentRequest(
              moveAction: MoveAction.undo,
              mailboxId: moveFolderRequest.destinationMailboxId,
              destinationMailboxId: moveFolderRequest.mailboxId,
              destinationMailboxDisplayName: '',
              totalEmails: moveFolderRequest.totalEmails,
            ),
          );
        },
      );
    }
  }

  void _undoMoveFolderContentAction({
    required MoveFolderContentRequest newMoveRequest,
  }) {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (accountId == null || session == null) {
      consumeState(
        Stream.value(
          Left(MoveFolderContentFailure(NotFoundAccountIdException())),
        ),
      );
      return;
    }

    consumeState(mailboxActionReactor.moveFolderContent(
      session: session,
      accountId: accountId,
      moveRequest: newMoveRequest,
      onProgressController: mailboxDashBoardController.progressStateController,
    ));
  }

  void handleMoveFolderContentFailure(MoveFolderContentFailure failure) {
    mailboxDashBoardController.syncViewStateMailboxActionProgress(
      newState: Right(UIState.idle),
    );
    toastManager.showMessageFailure(failure);
  }
}
