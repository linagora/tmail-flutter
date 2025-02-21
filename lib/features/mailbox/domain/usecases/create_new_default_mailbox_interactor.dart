import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/set_mailbox_method_exception.dart';
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
    try {
      yield dartz.Right<Failure, Success>(CreateDefaultMailboxLoading());
      final mailboxesRecord = await _mailboxRepository.createDefaultMailbox(
        session,
        accountId,
        listRole
      );

      final listMailboxCreated = mailboxesRecord.$1;
      log('CreateDefaultMailboxInteractor::execute:listMailboxCreated = $listMailboxCreated');
      if (listMailboxCreated.isEmpty) {
        yield dartz.Left<Failure, Success>(CreateDefaultMailboxFailure(NotFoundMailboxCreatedException()));
        return;
      }

      final listMailboxUpdated = await _updateRoleToListMailbox(
        session,
        accountId,
        listMailboxCreated,
      );

      yield dartz.Right<Failure, Success>(CreateDefaultMailboxAllSuccess(listMailboxUpdated));
    } catch (e) {
      yield dartz.Left<Failure, Success>(CreateDefaultMailboxFailure(e));
    }
  }

  Future<List<Mailbox>> _updateRoleToListMailbox(
    Session session,
    AccountId accountId,
    List<Mailbox> mailboxes,
  ) async {
    try {
      final mailboxUpdatedRecord = await _mailboxRepository.setRoleDefaultMailbox(
        session,
        accountId,
        mailboxes,
      );
      return mailboxUpdatedRecord.$1;
    } catch (e) {
      logError('CreateDefaultMailboxInteractor::_updateRoleToListMailbox:Exception = $e');
      return mailboxes;
    }
  }
}