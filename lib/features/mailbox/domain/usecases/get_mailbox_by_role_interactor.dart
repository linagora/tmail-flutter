import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_mailbox_by_role_state.dart';

class GetMailboxByRoleInteractor {
  final MailboxRepository _mailboxRepository;

  GetMailboxByRoleInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    Role role,
    {
      UnsignedInt? limit,
    }
  ) async* {
    try {
      yield Right(GetMailboxByRoleLoading());
      final response = await _mailboxRepository.getMailboxByRole(
        session,
        accountId,
        role,
        limit: limit
      );
      final mailbox = response.mailbox;
      if (mailbox != null) {
        yield Right(GetMailboxByRoleSuccess(mailbox));
      } else {
        yield Left(InvalidMailboxRole());
      }
    } catch (e) {
      yield Left(GetMailboxByRoleFailure(e));
    }
  }
}