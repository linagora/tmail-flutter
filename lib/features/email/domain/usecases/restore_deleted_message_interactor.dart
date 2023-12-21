import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/email/domain/model/restore_deleted_message_request.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/restore_deleted_message_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class RestoredDeletedMessageInteractor {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  RestoredDeletedMessageInteractor(this._emailRepository, this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    RestoredDeletedMessageRequest newRecoveryRequest,
  ) async* {
    try {
      yield Right<Failure, Success>(RestoreDeletedMessageLoading());
      final currentMailboxState = await _mailboxRepository.getMailboxState(session, accountId);
      final emailRecovery = await _emailRepository.restoreDeletedMessage(newRecoveryRequest);
      yield Right<Failure, Success>(RestoreDeletedMessageSuccess(emailRecovery, currentMailboxState: currentMailboxState));
    } catch (e) {
      yield Left<Failure, Success>(RestoreDeletedMessageFailure(e));
    }
  }
}