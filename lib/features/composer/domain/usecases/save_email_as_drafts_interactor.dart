import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class SaveEmailAsDraftsInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  SaveEmailAsDraftsInteractor(this._emailRepository, this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, Email email) async* {
    try {
      yield Right<Failure, Success>(SaveEmailAsDraftsLoading());

      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(),
        _emailRepository.getEmailState(),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final emailAsDrafts = await _emailRepository.saveEmailAsDrafts(accountId, email);
      if (emailAsDrafts != null) {
        yield Right<Failure, Success>(SaveEmailAsDraftsSuccess(
            emailAsDrafts,
            currentEmailState: currentEmailState,
            currentMailboxState: currentMailboxState));
      } else {
        yield Left<Failure, Success>(SaveEmailAsDraftsFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(SaveEmailAsDraftsFailure(e));
    }
  }
}