import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';

class EmptyTrashFolderInteractor {
  final ThreadRepository threadRepository;

  EmptyTrashFolderInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, MailboxId trashMailboxId) async* {
    try {
      yield Right<Failure, Success>(LoadingState());

      final result = await threadRepository.emptyTrashFolder(accountId, trashMailboxId);
      if (result) {
        yield Right<Failure, Success>(EmptyTrashFolderSuccess());
      } else {
        yield Left<Failure, Success>(EmptyTrashFolderFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(EmptyTrashFolderFailure(e));
    }
  }
}