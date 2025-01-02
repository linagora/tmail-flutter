import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_multiple_emails_permanently_state.dart';

class DeleteMultipleEmailsPermanentlyInteractor {
  final EmailRepository _emailRepository;

  DeleteMultipleEmailsPermanentlyInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    MailboxId? mailboxId,
  ) async* {
    try {
      yield Right<Failure, Success>(LoadingDeleteMultipleEmailsPermanentlyAll());
      final listResult = await _emailRepository.deleteMultipleEmailsPermanently(session, accountId, emailIds);
      if (listResult.emailIdsSuccess.length == emailIds.length) {
        yield Right<Failure, Success>(DeleteMultipleEmailsPermanentlyAllSuccess(listResult.emailIdsSuccess, mailboxId));
      } else if (listResult.emailIdsSuccess.isNotEmpty) {
        yield Right<Failure, Success>(DeleteMultipleEmailsPermanentlyHasSomeEmailFailure(listResult.emailIdsSuccess, mailboxId));
      } else {
        yield Left<Failure, Success>(DeleteMultipleEmailsPermanentlyAllFailure());
      }
    } catch (e) {
      yield Left<Failure, Success>(DeleteMultipleEmailsPermanentlyFailure(e));
    }
  }
}