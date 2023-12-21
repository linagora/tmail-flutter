import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:email_recovery/email_recovery/email_recovery_status.dart.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_restored_deleted_message_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';

class GetRestoredDeletedMessageInterator {
  final EmailRepository _emailRepository;
  final MailboxRepository _mailboxRepository;

  GetRestoredDeletedMessageInterator(this._emailRepository, this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    EmailRecoveryActionId emailRecoveryActionId,
  ) async* {
    try {
      yield Right<Failure, Success>(GetRestoredDeletedMessageLoading());
      
      final emailRecovery = await _emailRepository.getRestoredDeletedMessage(emailRecoveryActionId);

      switch (emailRecovery.status) {
        case EmailRecoveryStatus.completed:
          final getMailboxByRoleResponse = await _mailboxRepository.getMailboxByRole(
            session,
            accountId,
            Role('Restored-Messages')
          );
          final recoveredMailbox = getMailboxByRoleResponse.mailbox;

          yield Right<Failure, Success>(GetRestoredDeletedMessageCompleted(emailRecovery, recoveredMailbox: recoveredMailbox));
          break;
        case EmailRecoveryStatus.failed:
          yield Left<Failure, Success>(GetRestoredDeletedMessageFailure(null));
          break;
        case EmailRecoveryStatus.inProgress:
          yield Right<Failure, Success>(GetRestoredDeletedMessageInProgress(emailRecovery));
          break;
        case EmailRecoveryStatus.waiting:
          yield Right<Failure, Success>(GetRestoredDeletedMessageWaiting(emailRecovery));
          break;
        case EmailRecoveryStatus.canceled:
          yield Right<Failure, Success>(GetRestoredDeletedMessageCanceled(emailRecovery));
          break;
        default:
          yield Left<Failure, Success>(GetRestoredDeletedMessageFailure(null));
      }
    } catch (e) {
      yield Left<Failure, Success>(GetRestoredDeletedMessageFailure(e));
    }
  }
}