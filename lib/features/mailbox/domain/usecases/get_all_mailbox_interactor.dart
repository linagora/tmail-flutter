import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';

class GetAllMailboxInteractor {
  final MailboxRepository mailboxRepository;

  GetAllMailboxInteractor(this.mailboxRepository);

  Future<Either<Failure, Success>> execute(AccountId accountId, {Properties? properties}) async {
    try {
      final mailboxesList = await mailboxRepository.getAllMailbox(accountId, properties: properties);
      return Right(GetAllMailboxViewState(mailboxesList));
    } catch (e) {
      return Left(GetAllMailboxFailure(e));
    }
  }
}