import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/delete_all_permanently_emails_state.dart';

class DeleteAllPermanentlyEmailsInteractor {
  final ThreadRepository _threadRepository;

  DeleteAllPermanentlyEmailsInteractor(this._threadRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmails,
    StreamController<Either<Failure, Success>> onProgressController
  ) async* {
    try {
      yield Right<Failure, Success>(DeleteAllPermanentlyEmailsLoading());
      onProgressController.add(Right(DeleteAllPermanentlyEmailsLoading()));

      final emailIdDeleted = await _threadRepository.deleteAllPermanentlyEmails(
        session,
        accountId,
        mailboxId,
        totalEmails,
        onProgressController,
      );

      yield Right<Failure, Success>(DeleteAllPermanentlyEmailsSuccess(emailIdDeleted));
    } catch (e) {
      yield Left<Failure, Success>(DeleteAllPermanentlyEmailsFailure(e));
    }
  }
}