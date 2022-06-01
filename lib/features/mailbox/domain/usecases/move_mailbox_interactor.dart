import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_mailbox_state.dart';

class MoveMailboxInteractor {
  final MailboxRepository mailboxRepository;

  MoveMailboxInteractor(this.mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, MoveMailboxRequest request) async* {
    try {
      final result = await mailboxRepository.moveMailbox(accountId, request);
      if (result) {
        yield Right<Failure, Success>(MoveMailboxSuccess(
            request.mailboxId,
            request.moveAction,
            parentId: request.parentId,
            destinationMailboxId: request.destinationMailboxId,
            destinationMailboxName: request.destinationMailboxName));
      } else {
        yield Left<Failure, Success>(MoveMailboxFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(MoveMailboxFailure(e));
    }
  }
}