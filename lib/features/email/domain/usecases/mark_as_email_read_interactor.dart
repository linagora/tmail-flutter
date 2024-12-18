import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/email/read_actions.dart';
import 'package:tmail_ui_user/features/email/domain/model/mark_read_action.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class MarkAsEmailReadInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  MarkAsEmailReadInteractor(this._emailRepository, this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EmailId emailId,
    ReadActions readAction,
    MarkReadAction markReadAction,
  ) async* {
    try {
      final listState = await Future.wait([
        _mailboxRepository.getMailboxState( session,accountId),
        _emailRepository.getEmailState(session, accountId),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final result = await _emailRepository.markAsRead(
        session,
        accountId,
        [emailId],
        readAction,
      );

      yield Right(MarkAsEmailReadSuccess(
        result.first,
        readAction,
        markReadAction,
        currentEmailState: currentEmailState,
        currentMailboxState: currentMailboxState,
      ));
    } catch (e) {
      yield Left(MarkAsEmailReadFailure(readAction, exception: e));
    }
  }
}