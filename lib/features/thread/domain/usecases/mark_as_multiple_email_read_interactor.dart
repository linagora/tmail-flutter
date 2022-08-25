import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
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
      AccountId accountId,
      List<Email> emails,
      ReadActions readAction
  ) async* {
    try {
      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(),
        _emailRepository.getEmailState(),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final listEmailNeedMarkAsRead = emails
          .where((email) => readAction == ReadActions.markAsUnread ? email.hasRead : !email.hasRead)
          .toList();

      final result = await _emailRepository.markAsRead(accountId, listEmailNeedMarkAsRead, readAction);

      if (listEmailNeedMarkAsRead.length == result.length) {
        final countMarkAsReadSuccess = emails.length;
        yield Right(MarkAsMultipleEmailReadAllSuccess(
            countMarkAsReadSuccess,
            readAction,
            currentEmailState: currentEmailState,
            currentMailboxState: currentMailboxState));
      } else if (result.isEmpty) {
        yield Left(MarkAsMultipleEmailReadAllFailure(readAction));
      } else {
        final countMarkAsReadSuccess = emails.length - (listEmailNeedMarkAsRead.length - result.length);
        yield Right(MarkAsMultipleEmailReadHasSomeEmailFailure(
            countMarkAsReadSuccess,
            readAction,
            currentEmailState: currentEmailState,
            currentMailboxState: currentMailboxState));
      }
    } catch (e) {
      yield Left(MarkAsMultipleEmailReadFailure(e, readAction));
    }
  }
}