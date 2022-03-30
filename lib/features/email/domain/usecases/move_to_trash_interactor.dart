import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_trash_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_trash_state.dart';

class MoveToTrashInteractor {
  final EmailRepository emailRepository;

  MoveToTrashInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, MoveToTrashRequest moveRequest) async* {
    try {
      final result = await emailRepository.moveToTrash(accountId, moveRequest);
      if (result.isNotEmpty) {
        yield Right(MoveToTrashSuccess(
          result.first,
          moveRequest.currentMailboxId,
          moveRequest.trashMailboxId,
          moveRequest.moveAction));
      } else {
        yield Left(MoveToTrashFailure(null));
      }
    } catch (e) {
      yield Left(MoveToTrashFailure(e));
    }
  }
}