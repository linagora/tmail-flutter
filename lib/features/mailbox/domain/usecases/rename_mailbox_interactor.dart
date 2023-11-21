import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/rename_mailbox_state.dart';

class RenameMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  RenameMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, RenameMailboxRequest request) async* {
    try {
      yield Right<Failure, Success>(LoadingRenameMailbox());

      final currentMailboxState = await _mailboxRepository.getMailboxState(session, accountId);
      log('RenameMailboxInteractor::execute:currentMailboxState: $currentMailboxState');
      final result = await _mailboxRepository.renameMailbox(session, accountId, request);
      if (result) {
        yield Right<Failure, Success>(RenameMailboxSuccess(currentMailboxState: currentMailboxState));
      } else {
        yield Left<Failure, Success>(RenameMailboxFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(RenameMailboxFailure(e));
    }
  }
}