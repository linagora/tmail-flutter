import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class MarkAsEmailReadInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  MarkAsEmailReadInteractor(this._emailRepository, this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, Email email, ReadActions readAction) async* {
    try {
      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(),
        _emailRepository.getEmailState(),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final result = await _emailRepository.markAsRead(accountId, [email], readAction);
      if (result.isNotEmpty) {
        final updatedEmail = email.updatedEmail(newKeywords: result.first.keywords);
        yield Right(MarkAsEmailReadSuccess(
            updatedEmail,
            readAction,
            currentEmailState: currentEmailState,
            currentMailboxState: currentMailboxState));
      } else {
        yield Left(MarkAsEmailReadFailure(null, readAction));
      }
    } catch (e) {
      yield Left(MarkAsEmailReadFailure(e, readAction));
    }
  }
}