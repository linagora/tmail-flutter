import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_starred_selection_all_emails_state.dart';

class MarkAllAsStarredSelectionAllEmailsInteractor {
  final ThreadRepository _threadRepository;

  MarkAllAsStarredSelectionAllEmailsInteractor(this._threadRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    String mailboxDisplayName,
    int totalEmails,
    StreamController<Either<Failure, Success>> onProgressController
  ) async* {
    try {
      yield Right<Failure, Success>(MarkAllAsStarredSelectionAllEmailsLoading());
      onProgressController.add(Right(MarkAllAsStarredSelectionAllEmailsLoading()));

      final listEmailId = await _threadRepository.markAllAsStarredForSelectionAllEmails(
        session,
        accountId,
        mailboxId,
        totalEmails,
        onProgressController);

      if (listEmailId.isNotEmpty && totalEmails != listEmailId.length) {
        yield Right(MarkAllAsStarredSelectionAllEmailsHasSomeEmailFailure(listEmailId.length));
      } else {
        yield Right(MarkAllAsStarredSelectionAllEmailsAllSuccess());
      }
    } catch (e) {
      yield Left(MarkAllAsStarredSelectionAllEmailsFailure(exception: e));
    }
  }
}