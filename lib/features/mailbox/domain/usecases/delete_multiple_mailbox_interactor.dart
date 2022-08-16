import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';

class DeleteMultipleMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  DeleteMultipleMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, List<MailboxId> mailboxIds, MailboxId mailboxIdDeleted) async* {
    try {
      final currentMailboxState = await _mailboxRepository.getMailboxState();
      final result = await _mailboxRepository.deleteMultipleMailbox(session, accountId, mailboxIds);
      if (result) {
        yield Right<Failure, Success>(DeleteMultipleMailboxSuccess(
            mailboxIdDeleted,
            currentMailboxState: currentMailboxState));
      } else {
        yield Left<Failure, Success>(DeleteMultipleMailboxFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(DeleteMultipleMailboxFailure(e));
    }
  }
}