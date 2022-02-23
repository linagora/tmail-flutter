import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/create_new_mailbox_state.dart';

class CreateNewMailboxInteractor {
  final MailboxRepository mailboxRepository;

  CreateNewMailboxInteractor(this.mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, CreateNewMailboxRequest newMailboxRequest) async* {
    try {
      final newMailbox = await mailboxRepository.createNewMailbox(accountId, newMailboxRequest);
      if (newMailbox != null) {
        yield Right<Failure, Success>(CreateNewMailboxSuccess(newMailbox));
      } else {
        yield Left<Failure, Success>(CreateNewMailboxFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(CreateNewMailboxFailure(e));
    }
  }
}