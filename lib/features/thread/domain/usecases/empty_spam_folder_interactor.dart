import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';

class EmptySpamFolderInteractor {
  final ThreadRepository threadRepository;
  final MailboxRepository _mailboxRepository;
  final EmailRepository _emailRepository;

  EmptySpamFolderInteractor(
    this.threadRepository,
    this._mailboxRepository,
    this._emailRepository
  );

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, MailboxId spamMailboxId) async* {
    try {
      yield Right<Failure, Success>(EmptySpamFolderLoading());

      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(session, accountId),
        _emailRepository.getEmailState(session, accountId),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final emailIdDeleted = await threadRepository.emptySpamFolder(session, accountId, spamMailboxId);
      yield Right<Failure, Success>(EmptySpamFolderSuccess(
        emailIdDeleted,
        currentMailboxState: currentMailboxState,
        currentEmailState: currentEmailState,
      ));
    } catch (e) {
      yield Left<Failure, Success>(EmptySpamFolderFailure(e));
    }
  }
}