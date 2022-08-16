import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class DeleteMultipleEmailsPermanentlyInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  DeleteMultipleEmailsPermanentlyInteractor(this._emailRepository, this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, List<EmailId> emailIds) async* {
    try {
      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(),
        _emailRepository.getEmailState(),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final listResult = await _emailRepository.deleteMultipleEmailsPermanently(accountId, emailIds);
      if (listResult.length == emailIds.length) {
        yield Right<Failure, Success>(DeleteMultipleEmailsPermanentlyAllSuccess(
            listResult,
            currentEmailState: currentEmailState,
            currentMailboxState: currentMailboxState));
      } else if (listResult.isNotEmpty) {
        yield Right<Failure, Success>(DeleteMultipleEmailsPermanentlyHasSomeEmailFailure(
            listResult,
            currentEmailState: currentEmailState,
            currentMailboxState: currentMailboxState));
      } else {
        yield Left<Failure, Success>(DeleteMultipleEmailsPermanentlyAllFailure());
      }
    } catch (e) {
      yield Left<Failure, Success>(DeleteMultipleEmailsPermanentlyFailure(e));
    }
  }
}