import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/empty_spam_folder_state.dart';

class EmptySpamFolderInteractor {
  final ThreadRepository threadRepository;

  EmptySpamFolderInteractor(this.threadRepository);

  Stream<Either<Failure, Success>> execute(
    Session session, 
    AccountId accountId, 
    MailboxId spamMailboxId,
    int totalEmails,
    StreamController<Either<Failure, Success>> onProgressController
  ) async* {
    try {
      yield Right<Failure, Success>(EmptySpamFolderLoading());
      onProgressController.add(Right(EmptySpamFolderLoading()));
      
      final emailIdDeleted = await threadRepository.emptyMailboxFolder(
        session, 
        accountId, 
        spamMailboxId, 
        totalEmails, 
        onProgressController
      );
      yield Right<Failure, Success>(EmptySpamFolderSuccess(emailIdDeleted, spamMailboxId));
    } catch (e) {
      yield Left<Failure, Success>(EmptySpamFolderFailure(e));
    }
  }
}