import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subscribe_mailbox_state.dart';

class SearchMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  SearchMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, SubscribeMailboxRequest request) async* {
    try {
      yield Right<Failure, Success>(LoadingSubscribeMailbox());

      final resultList = await _mailboxRepository.subscribeMailbox(accountId, request);

      yield Right<Failure, Success>(SubscribeMailboxSuccess(resultList));
    } catch (exception) {
      yield Left<Failure, Success>(SubscribeMailboxFailure(exception));
    }
  }
}