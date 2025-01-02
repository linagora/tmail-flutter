import 'dart:async';

import 'package:core/presentation/extensions/map_extensions.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';

class MoveMultipleEmailToMailboxInteractor {
  final EmailRepository _emailRepository;

  MoveMultipleEmailToMailboxInteractor(this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest,
    Map<EmailId, bool> emailIdsWithReadStatus,
  ) async* {
    try {
      yield Right(LoadingMoveMultipleEmailToMailboxAll());
      final result = await _emailRepository.moveToMailbox(session, accountId, moveRequest);
      if (moveRequest.totalEmails == result.emailIdsSuccess.length) {
        yield Right(MoveMultipleEmailToMailboxAllSuccess(
          result.emailIdsSuccess,
          moveRequest.currentMailboxes.keys.first,
          moveRequest.destinationMailboxId,
          moveRequest.moveAction,
          moveRequest.emailActionType,
          destinationPath: moveRequest.destinationPath,
          originalMailboxIdsWithEmailIds: moveRequest.currentMailboxes,
          emailIdsWithReadStatus: emailIdsWithReadStatus,
        ));
      } else if (result.emailIdsSuccess.isEmpty) {
        yield Left(MoveMultipleEmailToMailboxAllFailure(moveRequest.moveAction, moveRequest.emailActionType));
      } else {
        final originalMailboxIdsWithEmailIds = Map<MailboxId, List<EmailId>>.from(
          moveRequest.currentMailboxes,
        );
        final originalMailboxIdsWithMoveSucceededEmailIds = originalMailboxIdsWithEmailIds
          .map((key, value) => MapEntry(
            key,
            value.where(result.emailIdsSuccess.contains).toList()
          ));
        final moveSucceededEmailIdsWithReadStatus = emailIdsWithReadStatus
          .where((emailId, _) => result.emailIdsSuccess.contains(emailId));
        yield Right(MoveMultipleEmailToMailboxHasSomeEmailFailure(
          result.emailIdsSuccess,
          moveRequest.currentMailboxes.keys.first,
          moveRequest.destinationMailboxId,
          moveRequest.moveAction,
          moveRequest.emailActionType,
          destinationPath: moveRequest.destinationPath,
          originalMailboxIdsWithMoveSucceededEmailIds: originalMailboxIdsWithMoveSucceededEmailIds,
          moveSucceededEmailIdsWithReadStatus: moveSucceededEmailIdsWithReadStatus,
        ));
      }
    } catch (e) {
      yield Left(MoveMultipleEmailToMailboxFailure(moveRequest.emailActionType, moveRequest.moveAction, e));
    }
  }
}