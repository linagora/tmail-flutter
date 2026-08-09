import 'package:core/presentation/extensions/either_stream_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/get_all_mailboxes_state.dart';

class GetAllMailboxInteractor {
  final MailboxRepository _mailboxRepository;

  GetAllMailboxInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(Session session, AccountId accountId, {Properties? properties}) async* {
    try {
      yield Right<Failure, Success>(GetAllMailboxLoading());

      yield* _mailboxRepository
        .getAllMailbox(
          session,
          accountId,
          properties: properties)
        .map((response) => _toGetMailboxState(response, accountId))
        .mapErrorToLeft((error, _) => GetAllMailboxFailure(
          error,
          onRetry: execute(session, accountId, properties: properties),
        ));
    } catch (e) {
      yield Left<Failure, Success>(GetAllMailboxFailure(
        e,
        onRetry: execute(session, accountId, properties: properties),
      ));
    }
  }

  Either<Failure, Success> _toGetMailboxState(
    MailboxResponse mailboxResponse,
    AccountId accountId,
  ) {
    // Stamp the account the mailboxes were fetched from. JMAP ids are only
    // unique within an account (RFC 8620), so a mailbox is not identifiable
    // without it once other users' accounts are also loaded.
    final mailboxList = mailboxResponse.mailboxes
      .map((mailbox) => mailbox.toPresentationMailbox(accountId: accountId))
      .toList();

    return Right<Failure, Success>(GetAllMailboxSuccess(
      mailboxList: mailboxList,
      currentMailboxState: mailboxResponse.state)
    );
  }
}