import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/domain/state/update_email_drafts_state.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class UpdateEmailDraftsInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  UpdateEmailDraftsInteractor(this._emailRepository, this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, Email newEmail, EmailId oldEmailId) async* {
    try {
      yield Right<Failure, Success>(UpdatingEmailDrafts());

      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(session, accountId),
        _emailRepository.getEmailState(session, accountId),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final newEmailDrafts = await _emailRepository.updateEmailDrafts(session, accountId, newEmail, oldEmailId);
      yield Right<Failure, Success>(
        UpdateEmailDraftsSuccess(
          newEmailDrafts.id!,
          currentEmailState: currentEmailState,
          currentMailboxState: currentMailboxState
        )
      );
    } catch (e) {
      yield Left<Failure, Success>(UpdateEmailDraftsFailure(e));
    }
  }
}