import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/create_default_mailbox_state.dart';

class CreateDefaultMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  CreateDefaultMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    List<Role> listRole
  ) async* {
    try {
      yield Right<Failure, Success>(CreateDefaultMailboxLoading());

      final currentMailboxState = await _mailboxRepository.getMailboxState(session, accountId);

      final listMailboxCreated = await _mailboxRepository.createDefaultMailbox(
        session,
        accountId,
        listRole
      );
      log('CreateDefaultMailboxInteractor::execute:listMailboxCreated: ${listMailboxCreated.length}');
      final listMailboxIdNotSetRole = await _mailboxRepository.setRoleDefaultMailbox(
        session,
        accountId,
        listMailboxCreated
      );
      log('CreateDefaultMailboxInteractor::execute:listMailboxIdNotSetRole: ${listMailboxIdNotSetRole.length}');
      if (listMailboxIdNotSetRole.isEmpty) {
        yield Right<Failure, Success>(CreateDefaultMailboxAllSuccess(currentMailboxState: currentMailboxState));
      } else if (listMailboxIdNotSetRole.length < listMailboxCreated.length) {
        yield Right<Failure, Success>(CreateDefaultMailboxHasSomeFailure(currentMailboxState: currentMailboxState));
      } else {
        final mapError = await _mailboxRepository.deleteMultipleMailbox(
          session,
          accountId,
          listMailboxIdNotSetRole
        );
        yield Left<Failure, Success>(CreateDefaultMailboxFailure(mapError));
      }
    } catch (e) {
      yield Left<Failure, Success>(CreateDefaultMailboxFailure(e));
    }
  }
}