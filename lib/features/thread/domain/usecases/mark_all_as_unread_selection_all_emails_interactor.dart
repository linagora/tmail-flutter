import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/thread_repository.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_all_as_unread_selection_all_emails_state.dart';

class MarkAllAsUnreadSelectionAllEmailsInteractor {
  final MailboxRepository _mailboxRepository;
  final EmailRepository _emailRepository;
  final ThreadRepository _threadRepository;

  MarkAllAsUnreadSelectionAllEmailsInteractor(
    this._mailboxRepository,
    this._emailRepository,
    this._threadRepository,
  );

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    String mailboxDisplayName,
    int totalEmailRead,
    StreamController<Either<Failure, Success>> onProgressController
  ) async* {
    try {
      yield Right<Failure, Success>(MarkAllAsUnreadSelectionAllEmailsLoading());
      onProgressController.add(Right(MarkAllAsUnreadSelectionAllEmailsLoading()));

      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(session, accountId),
        _emailRepository.getEmailState(session, accountId),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final listEmailId = await _threadRepository.markAllAsUnreadForSelectionAllEmails(
        session,
        accountId,
        mailboxId,
        totalEmailRead,
        onProgressController);

      if (totalEmailRead == listEmailId.length) {
        yield Right(MarkAllAsUnreadSelectionAllEmailsAllSuccess(
          currentEmailState: currentEmailState,
          currentMailboxState: currentMailboxState));
      } else if (listEmailId.isNotEmpty) {
        yield Right(MarkAllAsUnreadSelectionAllEmailsHasSomeEmailFailure(
          listEmailId.length,
          currentEmailState: currentEmailState,
          currentMailboxState: currentMailboxState));
      } else {
        yield Left(MarkAllAsUnreadSelectionAllEmailsAllFailure());
      }
    } catch (e) {
      yield Left(MarkAllAsUnreadSelectionAllEmailsFailure(exception: e));
    }
  }
}