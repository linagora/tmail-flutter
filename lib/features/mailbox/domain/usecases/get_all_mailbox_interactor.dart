import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';

class GetAllMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  GetAllMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, {Properties? properties}) async* {
    try {
      yield Right<Failure, Success>(LoadingState());

      yield* _mailboxRepository
        .getAllMailbox(accountId, properties: properties)
        .map(_toGetMailboxState);
    } catch (e) {
      yield Left<Failure, Success>(GetAllMailboxFailure(e));
    }
  }

  Either<Failure, Success> _toGetMailboxState(MailboxResponse mailboxResponse) {
    final mailboxList = mailboxResponse.mailboxes
      ?.map((mailbox) => mailbox.toPresentationMailbox()).toList()
      ?? List<PresentationMailbox>.empty();

    return Right<Failure, Success>(GetAllMailboxSuccess(
      mailboxList: mailboxList,
      currentMailboxState: mailboxResponse.state)
    );
  }
}