import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/delete_email_permanently_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class DeleteEmailPermanentlyInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  DeleteEmailPermanentlyInteractor(this._emailRepository, this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, EmailId emailId) async* {
    try {
      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(),
        _emailRepository.getEmailState(),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final result = await _emailRepository.deleteEmailPermanently(accountId, emailId);
      if (result) {
        yield Right<Failure, Success>(DeleteEmailPermanentlySuccess(
            currentEmailState: currentEmailState,
            currentMailboxState: currentMailboxState));
      } else {
        yield Left<Failure, Success>(DeleteEmailPermanentlyFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(DeleteEmailPermanentlyFailure(e));
    }
  }
}