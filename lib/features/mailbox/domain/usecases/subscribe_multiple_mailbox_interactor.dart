import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_multiple_mailbox_state.dart';

class SubscribeMultipleMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  SubscribeMultipleMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, SubscribeMultipleMailboxRequest subscribeRequest) async* {
    try {
      yield Right<Failure, Success>(LoadingSubscribeMultipleMailbox());

      final currentMailboxState = await _mailboxRepository.getMailboxState();
      final listResult = await _mailboxRepository.subscribeMultipleMailbox(accountId, subscribeRequest);

      final matchedSize = listResult.length == subscribeRequest.mailboxIdsSubscribe.length;
      final allMatchedMailboxIdSubscribe = subscribeRequest.mailboxIdsSubscribe
        .every((mailboxId) => listResult.contains(mailboxId));

      if (allMatchedMailboxIdSubscribe && matchedSize) {
        yield Right<Failure, Success>(SubscribeMultipleMailboxAllSuccess(
          subscribeRequest.parentMailboxId,
          listResult,
          subscribeRequest.subscribeAction,
          currentMailboxState: currentMailboxState
        ));
      } else if (listResult.isEmpty) {
        yield Left<Failure, Success>(SubscribeMultipleMailboxAllFailure());
      } else {
        yield Right<Failure, Success>(SubscribeMultipleMailboxHasSomeSuccess(
          subscribeRequest.parentMailboxId,
          listResult,
          subscribeRequest.subscribeAction,
          currentMailboxState: currentMailboxState
        ));
      }
    } catch (e) {
      yield Left<Failure, Success>(SubscribeMultipleMailboxFailure(e));
    }
  }
}