import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_trash_folder_state.dart';

class EmptyTrashFolderInteractor {
  final ThreadRepository threadRepository;
  final MailboxRepository _mailboxRepository;
  final EmailRepository _emailRepository;

  EmptyTrashFolderInteractor(
    this.threadRepository,
    this._mailboxRepository,
    this._emailRepository
  );

  Stream<Either<Failure, Success>> execute(AccountId accountId, MailboxId trashMailboxId) async* {
    try {
      yield Right<Failure, Success>(LoadingState());

      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(),
        _emailRepository.getEmailState(),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final result = await threadRepository.emptyTrashFolder(accountId, trashMailboxId);
      if (result.isNotEmpty) {
        yield Right<Failure, Success>(EmptyTrashFolderSuccess(
          currentMailboxState: currentMailboxState,
          currentEmailState: currentEmailState,
        ));
      } else {
        yield Left<Failure, Success>(EmptyTrashFolderFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(EmptyTrashFolderFailure(e));
    }
  }
}