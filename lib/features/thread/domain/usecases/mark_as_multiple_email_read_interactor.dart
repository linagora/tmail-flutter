import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';

class MarkAsMultipleEmailReadInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  MarkAsMultipleEmailReadInteractor(this._emailRepository, this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    ReadActions readAction
  ) async* {
    try {
      yield Right(LoadingMarkAsMultipleEmailReadAll());

      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(session, accountId),
        _emailRepository.getEmailState(session, accountId),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final result = await _emailRepository.markAsRead(
        session,
        accountId,
        emailIds,
        readAction,
      );

      if (emailIds.length == result.length) {
        yield Right(MarkAsMultipleEmailReadAllSuccess(
            result.length,
            readAction,
            currentEmailState: currentEmailState,
            currentMailboxState: currentMailboxState));
      } else if (result.isEmpty) {
        yield Left(MarkAsMultipleEmailReadAllFailure(readAction));
      } else {
        yield Right(MarkAsMultipleEmailReadHasSomeEmailFailure(
            result.length,
            readAction,
            currentEmailState: currentEmailState,
            currentMailboxState: currentMailboxState));
      }
    } catch (e) {
      yield Left(MarkAsMultipleEmailReadFailure(readAction, e));
    }
  }
}