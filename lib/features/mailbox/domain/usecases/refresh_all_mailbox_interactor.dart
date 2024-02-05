import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart' as jmap_state;
import 'package:model/extensions/mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/refresh_changes_all_mailboxes_state.dart';

class RefreshAllMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  RefreshAllMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    jmap_state.State currentState,
    {Properties? properties}
  ) async* {
    try {
      log('RefreshAllMailboxInteractor::execute:properties: $properties');
      yield Right<Failure, Success>(RefreshChangesAllMailboxLoading());
      yield* _mailboxRepository
        .refresh(session, accountId, currentState, properties: properties)
        .map(_toGetMailboxState);
    } catch (e) {
      yield Left<Failure, Success>(RefreshChangesAllMailboxFailure(e));
    }
  }

  Either<Failure, Success> _toGetMailboxState(MailboxResponse mailboxResponse) {
    final mailboxList = mailboxResponse.mailboxes
      .map((mailbox) => mailbox.toPresentationMailbox())
      .toList();

    return Right<Failure, Success>(RefreshChangesAllMailboxSuccess(
        mailboxList: mailboxList,
        currentMailboxState: mailboxResponse.state)
    );
  }
}