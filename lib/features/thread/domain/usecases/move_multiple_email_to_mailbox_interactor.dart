import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_multiple_email_to_mailbox_state.dart';

class MoveMultipleEmailToMailboxInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  MoveMultipleEmailToMailboxInteractor(this._emailRepository, this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(AccountId accountId, MoveToMailboxRequest moveRequest) async* {
    try {
      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(),
        _emailRepository.getEmailState(),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final result = await _emailRepository.moveToMailbox(accountId, moveRequest);
      int totalEmail = 0;
      for (var element in moveRequest.currentMailboxes.values) {
        totalEmail = totalEmail + element.length;
      }if (totalEmail == result.length) {
        yield Right(MoveMultipleEmailToMailboxAllSuccess(
          result,
          moveRequest.currentMailboxes.keys.first,
          moveRequest.destinationMailboxId,
          moveRequest.moveAction,
          moveRequest.emailActionType,
          destinationPath: moveRequest.destinationPath,
          currentEmailState: currentEmailState,
          currentMailboxState: currentMailboxState));
      } else if (result.isEmpty) {
        yield Left(MoveMultipleEmailToMailboxAllFailure(moveRequest.moveAction, moveRequest.emailActionType));
      } else {
        yield Right(MoveMultipleEmailToMailboxHasSomeEmailFailure(
          result,
          moveRequest.currentMailboxes.keys.first,
          moveRequest.destinationMailboxId,
          moveRequest.moveAction,
          moveRequest.emailActionType,
          destinationPath: moveRequest.destinationPath,
          currentEmailState: currentEmailState,
          currentMailboxState: currentMailboxState));
      }
    } catch (e) {
      yield Left(MoveMultipleEmailToMailboxFailure(e, moveRequest.emailActionType, moveRequest.moveAction));
    }
  }
}