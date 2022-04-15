import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';

class MoveMultipleEmailToMailboxInteractor {
  final EmailRepository _emailRepository;

  MoveMultipleEmailToMailboxInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, MoveToMailboxRequest moveRequest) async* {
    try {
      final result = await _emailRepository.moveToMailbox(accountId, moveRequest);

      if (moveRequest.emailIds.length == result.length) {
        yield Right(MoveMultipleEmailToMailboxAllSuccess(
          result,
          moveRequest.currentMailboxId,
          moveRequest.destinationMailboxId,
          moveRequest.moveAction,
          moveRequest.emailActionType,
          destinationPath: moveRequest.destinationPath));
      } else if (result.isEmpty) {
        yield Left(MoveMultipleEmailToMailboxAllFailure(moveRequest.moveAction, moveRequest.emailActionType));
      } else {
        yield Right(MoveMultipleEmailToMailboxHasSomeEmailFailure(
          result,
          moveRequest.currentMailboxId,
          moveRequest.destinationMailboxId,
          moveRequest.moveAction,
          moveRequest.emailActionType,
          destinationPath: moveRequest.destinationPath));
      }
    } catch (e) {
      yield Left(MoveMultipleEmailToMailboxFailure(e, moveRequest.emailActionType, moveRequest.moveAction));
    }
  }
}