import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/move_mailbox_state.dart';

class MoveMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  MoveMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, MoveMailboxRequest request) async* {
    try {
      yield Right<Failure, Success>(LoadingMoveMailbox());
      final result = await _mailboxRepository.moveMailbox(session, accountId, request);
      if (result) {
        yield Right<Failure, Success>(MoveMailboxSuccess(
            request.mailboxId,
            request.moveAction,
            parentId: request.parentId,
            destinationMailboxId: request.destinationMailboxId,
            destinationMailboxDisplayName: request.destinationMailboxDisplayName,
        ));
      } else {
        yield Left<Failure, Success>(MoveMailboxFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(MoveMailboxFailure(e));
    }
  }
}