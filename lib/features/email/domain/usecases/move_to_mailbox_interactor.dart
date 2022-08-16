import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class MoveToMailboxInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  MoveToMailboxInteractor(this._emailRepository, this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, MoveToMailboxRequest moveRequest) async* {
    try {
      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(),
        _emailRepository.getEmailState(),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final result = await _emailRepository.moveToMailbox(accountId, moveRequest);
      if (result.isNotEmpty) {
        yield Right(MoveToMailboxSuccess(
          result.first,
          moveRequest.currentMailboxId,
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