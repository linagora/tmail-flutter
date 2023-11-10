import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/create_default_mailbox_state.dart';

class CreateDefaultMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  CreateDefaultMailboxInteractor(this._mailboxRepository);

  Stream<dartz.Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    List<Role> listRole
  ) async* {
    final currentMailboxState = await _getCurrentMailboxState(session, accountId);
    try {
      yield dartz.Right<Failure, Success>(CreateDefaultMailboxLoading());
      final listMailboxCreated = await _mailboxRepository.createDefaultMailbox(
        session,
        accountId,
        listRole
      );
      await _mailboxRepository.setRoleDefaultMailbox(
        session,
        accountId,
        listMailboxCreated
      );
      yield dartz.Right<Failure, Success>(CreateDefaultMailboxAllSuccess(currentMailboxState: currentMailboxState));
    } catch (e) {
      yield dartz.Left<Failure, Success>(CreateDefaultMailboxFailure(currentMailboxState, e));
    }
  }

  Future<State?> _getCurrentMailboxState(Session session, AccountId accountId) async {
    try {
      final currentMailboxState = await _mailboxRepository.getMailboxState(session, accountId);
      log('CreateDefaultMailboxInteractor::_getCurrentMailboxState:currentMailboxState: $currentMailboxState');
      return currentMailboxState;
    } catch (e) {
      return null;
    }
  }
}