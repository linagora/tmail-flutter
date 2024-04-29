import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/move_all_selection_all_emails_state.dart';

class MoveAllSelectionAllEmailsInteractor {
  final ThreadRepository _threadRepository;

  MoveAllSelectionAllEmailsInteractor(this._threadRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    MailboxId currentMailboxId,
    Mailbox destinationMailbox,
    String destinationPath,
    int totalEmails,
    StreamController<Either<Failure, Success>> onProgressController,
  ) async* {
    try {
      yield Right(MoveAllSelectionAllEmailsLoading());
      onProgressController.add(Right(MoveAllSelectionAllEmailsLoading()));

      final listEmailId = await _threadRepository.moveAllSelectionAllEmails(
        session,
        accountId,
        currentMailboxId,
        destinationMailbox,
        totalEmails,
        onProgressController);

      if (totalEmails == listEmailId.length) {
        yield Right(MoveAllSelectionAllEmailsAllSuccess(destinationPath));
      } else if (listEmailId.isNotEmpty) {
        yield Right(MoveAllSelectionAllEmailsHasSomeEmailFailure(
          destinationPath,
          listEmailId.length,
        ));
      } else {
        yield Left(MoveAllSelectionAllEmailsAllFailure(destinationPath));
      }
    } catch (e) {
      yield Left(MoveAllSelectionAllEmailsFailure(
        destinationPath: destinationPath,
        exception: e,
      ));
    }
  }
}