import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/mark_as_mailbox_read_state.dart';

class MarkAsMailboxReadInteractor {
  final MailboxRepository _mailboxRepository;

  MarkAsMailboxReadInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId,
      MailboxId mailboxId, MailboxName mailboxName) async* {
    try {
      yield Right<Failure, Success>(MarkAsMailboxReadLoading());
      final result = await _mailboxRepository.markAsMailboxRead(accountId, mailboxId, mailboxName);
      if (result) {
        yield Right(MarkAsMailboxReadAllSuccess(mailboxName));
      } else {
        yield Left(MarkAsMailboxReadHasSomeEmailFailure());
      }
    } catch (e) {
      yield Left(MarkAsMailboxReadFailure(e));
    }
  }
}