import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/move_to_mailbox_state.dart';

class MoveToMailboxInteractor {
  final EmailRepository _emailRepository;

  MoveToMailboxInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus,
  ) async* {
    try {
      yield Right(LoadingMoveToMailbox());
      final result = await _emailRepository.moveToMailbox(session, accountId, moveRequest);
      if (result.emailIdsSuccess.isNotEmpty) {
        yield Right(MoveToMailboxSuccess(
          result.emailIdsSuccess.first,
          moveRequest.currentMailboxes.keys.first,
          moveRequest.destinationMailboxId,
          moveRequest.moveAction,
          moveRequest.emailActionType,
          destinationPath: moveRequest.destinationPath,
          originalMailboxIdsWithEmailIds: moveRequest.currentMailboxes,
          emailIdsWithReadStatus: emailIdsWithReadStatus,
        ));
      } else {
        yield Left(MoveToMailboxFailure(moveRequest.emailActionType));
      }
    } catch (e) {
      yield Left(MoveToMailboxFailure(moveRequest.emailActionType, exception: e));
    }
  }
}