import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/clear_mailbox_state.dart';

class ClearMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  ClearMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    Role mailboxRole,
  ) async* {
    try {
      yield Right<Failure, Success>(ClearingMailbox());
      final totalDeletedMessages = await _mailboxRepository.clearMailbox(
        session,
        accountId,
        mailboxId,
      );
      yield Right<Failure, Success>(ClearMailboxSuccess(
        mailboxId,
        mailboxRole,
        totalDeletedMessages,
      ));
    } catch (e) {
      yield Left<Failure, Success>(ClearMailboxFailure(mailboxRole, exception: e));
    }
  }
}
