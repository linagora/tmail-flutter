import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_right_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subaddressing_mailbox_state.dart';

class SubaddressingInteractor {
  final MailboxRepository _mailboxRepository;

  SubaddressingInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, MailboxRightRequest mailboxRightRequest) async* {
    try {
      yield Right<Failure, Success>(LoadingSubaddressingMailbox());

      final currentMailboxState = await _mailboxRepository.getMailboxState(session, accountId);

      final result = await _mailboxRepository.handleMailboxRightRequest(session, accountId, mailboxRightRequest);

      if (result) {
        yield Right<Failure, Success>(SubaddressingSuccess(
          mailboxRightRequest.mailboxId, 
          currentMailboxState: currentMailboxState,
          mailboxRightRequest.subaddressingAction));
      } else {
        yield Left<Failure, Success>(SubaddressingFailure(null));
      }

    } catch (exception) {
      yield Left<Failure, Success>(SubaddressingFailure(exception));
    }
  }
}