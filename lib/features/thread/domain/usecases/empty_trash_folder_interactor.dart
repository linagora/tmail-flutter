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
      final emailIdDeleted = await threadRepository.emptyTrashFolder(session, accountId, trashMailboxId);
      yield Right<Failure, Success>(EmptyTrashFolderSuccess(emailIdDeleted,));
    } catch (e) {
      yield Left<Failure, Success>(EmptyTrashFolderFailure(e));
    }
  }
}