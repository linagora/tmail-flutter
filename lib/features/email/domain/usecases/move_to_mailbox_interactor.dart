import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';

class MoveToMailboxInteractor {
  final EmailRepository emailRepository;

  MoveToMailboxInteractor(this.emailRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, MoveToMailboxRequest moveRequest) async* {
    try {
      final result = await emailRepository.moveToMailbox(accountId, moveRequest);
      if (result.isNotEmpty) {
        yield Right(MoveToMailboxSuccess(
          result.first,
          moveRequest.currentMailboxId,
          moveRequest.destinationMailboxId,
          moveRequest.moveAction,
          moveRequest.emailActionType,
          destinationPath: moveRequest.destinationPath));
      } else {
        yield Left(MoveToMailboxFailure(moveRequest.emailActionType, null));
      }
    } catch (e) {
      yield Left(MoveToMailboxFailure(moveRequest.emailActionType, e));
    }
  }
}