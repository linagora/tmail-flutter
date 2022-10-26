import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/delete_multiple_mailbox_state.dart';

class DeleteMultipleMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  DeleteMultipleMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
      Session session,
      AccountId accountId,
      Map<MailboxId, List<MailboxId>> mapMailboxIdToDelete,
      List<MailboxId> listMailboxIdToDelete
  ) async* {
    try {
      final currentMailboxState = await _mailboxRepository.getMailboxState();

      final listResult = await Future.wait(
          mapMailboxIdToDelete.keys.map((mailboxId) {
            final mailboxIdsToDelete = mapMailboxIdToDelete[mailboxId]!;
            return _mailboxRepository.deleteMultipleMailbox(
                session,
                accountId,
                mailboxIdsToDelete);
          })
      );

      final allSuccess = listResult.every((result) => result);
      final allFailed = listResult.every((result) => !result);

      if (allSuccess) {
        yield Right<Failure, Success>(DeleteMultipleMailboxAllSuccess(
            listMailboxIdToDelete,
            currentMailboxState: currentMailboxState));
      } else if (allFailed) {
        yield Left<Failure, Success>(DeleteMultipleMailboxAllFailure());
      } else {
        yield Right<Failure, Success>(DeleteMultipleMailboxHasSomeSuccess(
            listMailboxIdToDelete,
            currentMailboxState: currentMailboxState));
      }
    } catch (e) {
      logError('DeleteMultipleMailboxInteractor::execute(): exception: $e');
      yield Left<Failure, Success>(DeleteMultipleMailboxFailure(e));
    }
  }
}