import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class MoveToMailboxInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  MoveToMailboxInteractor(this._emailRepository, this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, MoveToMailboxRequest moveRequest) async* {
    try {
      yield Right(LoadingMoveToMailbox());

      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(accountId),
        _emailRepository.getEmailState(accountId),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final result = await _emailRepository.moveToMailbox(session, accountId, moveRequest);
      if (result.isNotEmpty) {
        yield Right(MoveToMailboxSuccess(
          result.first,
          moveRequest.currentMailboxes.keys.first,
          moveRequest.destinationMailboxId,
          moveRequest.moveAction,
          moveRequest.emailActionType,
          destinationPath: moveRequest.destinationPath,
          currentMailboxState: currentMailboxState,
          currentEmailState: currentEmailState));
      } else {
        yield Left(MoveToMailboxFailure(moveRequest.emailActionType, null));
      }
    } catch (e) {
      yield Left(MoveToMailboxFailure(moveRequest.emailActionType, e));
    }
  }
}