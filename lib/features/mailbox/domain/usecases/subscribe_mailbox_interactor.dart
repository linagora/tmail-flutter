import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_mailbox_state.dart';

class SubscribeMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  SubscribeMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, SubscribeMailboxRequest request) async* {
    try {
      yield Right<Failure, Success>(LoadingSubscribeMailbox());

      final currentMailboxState = await _mailboxRepository.getMailboxState(accountId);

      final result = await _mailboxRepository.subscribeMailbox(session, accountId, request);

      if (result) {
        yield Right<Failure, Success>(SubscribeMailboxSuccess(
          request.mailboxId, 
          currentMailboxState: currentMailboxState,
          request.subscribeAction));
      } else {
        yield Left<Failure, Success>(SubscribeMailboxFailure(null));
      }

    } catch (exception) {
      yield Left<Failure, Success>(SubscribeMailboxFailure(exception));
    }
  }
}