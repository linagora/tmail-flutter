import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';

class EmptyTrashFolderInteractor {
  final ThreadRepository threadRepository;

  EmptyTrashFolderInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, MailboxId trashMailboxId) async* {
    try {
      yield Right<Failure, Success>(EmptyTrashFolderLoading());
      final success = await threadRepository.emptyTrashFolder(session, accountId, trashMailboxId);
      final finalState = success ? Right<Failure, Success>(EmptyTrashFolderSuccess())
        : Left<Failure, Success>(EmptyTrashFolderFailure(CannotEmptyTrashException()));
      yield finalState;
    } catch (e) {
      yield Left<Failure, Success>(EmptyTrashFolderFailure(e));
    }
  }
}