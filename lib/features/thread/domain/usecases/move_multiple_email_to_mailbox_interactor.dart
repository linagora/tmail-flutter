import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';

class MoveMultipleEmailToMailboxInteractor {
  final EmailRepository _emailRepository;

  MoveMultipleEmailToMailboxInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest
  ) async* {
    try {
      yield Right(LoadingMoveMultipleEmailToMailboxAll());
      final result = await _emailRepository.moveToMailbox(session, accountId, moveRequest);
      if (moveRequest.totalEmails == result.emailIdsSuccess.length) {
        yield Right(MoveMultipleEmailToMailboxAllSuccess(
          result.emailIdsSuccess,
          moveRequest.currentMailboxes.keys.first,
          moveRequest.destinationMailboxId,
          moveRequest.moveAction,
          moveRequest.emailActionType,
          destinationPath: moveRequest.destinationPath,
        ));
      } else if (result.emailIdsSuccess.isEmpty) {
        yield Left(MoveMultipleEmailToMailboxAllFailure(moveRequest.moveAction, moveRequest.emailActionType));
      } else {
        yield Right(MoveMultipleEmailToMailboxHasSomeEmailFailure(
          result.emailIdsSuccess,
          moveRequest.currentMailboxes.keys.first,
          moveRequest.destinationMailboxId,
          moveRequest.moveAction,
          moveRequest.emailActionType,
          destinationPath: moveRequest.destinationPath,
        ));
      }
    } catch (e) {
      yield Left(MoveMultipleEmailToMailboxFailure(moveRequest.emailActionType, moveRequest.moveAction, e));
    }
  }
}