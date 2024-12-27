import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';

class EmptySpamFolderInteractor {
  final ThreadRepository threadRepository;

  EmptySpamFolderInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, MailboxId spamMailboxId) async* {
    try {
      yield Right<Failure, Success>(EmptySpamFolderLoading());
      final success = await threadRepository.emptySpamFolder(session, accountId, spamMailboxId);
      final finalState = success ? Right<Failure, Success>(EmptySpamFolderSuccess()) 
        : Left<Failure, Success>(EmptySpamFolderFailure(CannotEmptySpamFolderException()));
      yield finalState;
    } catch (e) {
      yield Left<Failure, Success>(EmptySpamFolderFailure(e));
    }
  }
}