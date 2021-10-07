import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/list_mailbox_extension.dart';
import 'package:model/model.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmapState;

class RefreshAllMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  RefreshAllMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, jmapState.State currentState) async* {
    try {
      yield Right<Failure, Success>(LoadingState());

      yield* _mailboxRepository
        .refresh(accountId, currentState)
        .map(_toGetMailboxState);
    } catch (e) {
      yield Left<Failure, Success>(GetAllMailboxFailure(e));
    }
  }

  Either<Failure, Success> _toGetMailboxState(MailboxResponse mailboxResponse) {
    final tupleList = mailboxResponse.mailboxes
      ?.splitMailboxList((mailbox) => mailbox.hasRole()) ?? Tuple2([], []);

    return Right<Failure, Success>(GetAllMailboxSuccess(
      defaultMailboxList: tupleList.value1,
      folderMailboxList: tupleList.value2,
      currentMailboxState: mailboxResponse.state));
  }
}