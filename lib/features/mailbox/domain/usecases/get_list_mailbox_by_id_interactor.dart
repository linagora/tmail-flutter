import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_list_mailbox_by_id_state.dart';

class GetListMailboxByIdInteractor {
  final MailboxRepository _mailboxRepository;

  GetListMailboxByIdInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    List<MailboxId> mailboxIds
  ) async* {
    try {
      yield Right<Failure, Success>(GetListMailboxByIdLoading());
      final mailboxIdsExist = await _mailboxRepository.getListMailboxById(session, accountId, mailboxIds);
      yield Right<Failure, Success>(GetListMailboxByIdSuccess(mailboxIdsExist));
    } catch (e) {
      yield Left<Failure, Success>(GetListMailboxByIdFailure(e));
    }
  }
}