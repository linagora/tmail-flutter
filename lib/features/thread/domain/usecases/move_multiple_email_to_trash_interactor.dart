import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_trash_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_trash_state.dart';

class MoveMultipleEmailToTrashInteractor {
  final EmailRepository _emailRepository;

  MoveMultipleEmailToTrashInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, MoveToTrashRequest moveRequest) async* {
    try {
      final result = await _emailRepository.moveToTrash(accountId, moveRequest);

      if (moveRequest.emailIds.length == result.length) {
        yield Right(MoveMultipleEmailToTrashAllSuccess(
          result,
          moveRequest.currentMailboxId,
          moveRequest.trashMailboxId,
          moveRequest.moveAction));
      } else if (result.isEmpty) {
        yield Left(MoveMultipleEmailToTrashAllFailure(moveRequest.moveAction));
      } else {
        yield Right(MoveMultipleEmailToTrashHasSomeEmailFailure(
          result,
          moveRequest.currentMailboxId,
          moveRequest.trashMailboxId,
          moveRequest.moveAction));
      }
    } catch (e) {
      yield Left(MoveMultipleEmailToTrashFailure(e, moveRequest.moveAction));
    }
  }
}