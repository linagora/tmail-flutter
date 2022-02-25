import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/rename_mailbox_state.dart';

class RenameMailboxInteractor {
  final MailboxRepository mailboxRepository;

  RenameMailboxInteractor(this.mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, RenameMailboxRequest request) async* {
    try {
      final result = await mailboxRepository.renameMailbox(accountId, request);
      if (result) {
        yield Right<Failure, Success>(RenameMailboxSuccess());
      } else {
        yield Left<Failure, Success>(RenameMailboxFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(RenameMailboxFailure(e));
    }
  }
}