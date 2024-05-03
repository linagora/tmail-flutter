import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/email/domain/repository/email_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';

class MarkAsMailboxReadInteractor {
  final MailboxRepository _mailboxRepository;
  final EmailRepository _emailRepository;

  MarkAsMailboxReadInteractor(this._mailboxRepository, this._emailRepository);

  Stream<Either<Failure, Success>> execute(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    String mailboxDisplayName,
    int totalEmailUnread,
    StreamController<Either<Failure, Success>> onProgressController
  ) async* {
    try {
      yield Right<Failure, Success>(MarkAsMailboxReadLoading());
      onProgressController.add(Right(MarkAsMailboxReadLoading()));

      final listState = await Future.wait([
        _mailboxRepository.getMailboxState(session, accountId),
        _emailRepository.getEmailState(session, accountId),
      ], eagerError: true);

      final currentMailboxState = listState.first;
      final currentEmailState = listState.last;

      final listEmailId = await _mailboxRepository.markAsMailboxRead(
        session,
        accountId,
        mailboxId,
        totalEmailUnread,
        onProgressController);

      if (totalEmailUnread == listEmailId.length) {
        yield Right(MarkAsMailboxReadAllSuccess(
            mailboxId,
          mailboxDisplayName,
          currentEmailState: currentEmailState,
          currentMailboxState: currentMailboxState));
      } else if (listEmailId.isNotEmpty) {
        yield Right(MarkAsMailboxReadHasSomeEmailFailure(
          mailboxId,
          mailboxDisplayName,
          listEmailId.length,
          currentEmailState: currentEmailState,
          currentMailboxState: currentMailboxState));
      } else {
        yield Left(MarkAsMailboxReadAllFailure(mailboxDisplayName: mailboxDisplayName));
      }
    } catch (e) {
      yield Left(MarkAsMailboxReadFailure(
        mailboxDisplayName: mailboxDisplayName,
        exception: e
      ));
    }
  }
}