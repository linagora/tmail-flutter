import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/repository/mailbox_repository.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/mark_as_mailbox_read_state.dart';

class MarkAsMailboxReadInteractor {
  final MailboxRepository _mailboxRepository;

  MarkAsMailboxReadInteractor(this._mailboxRepository);

  Stream<Either<Failure, Success>> execute(
      AccountId accountId,
      MailboxId mailboxId,
      MailboxName mailboxName,
      int totalEmailUnread,
      StreamController<Either<Failure, Success>> onProgressController
  ) async* {
    try {
      yield Right<Failure, Success>(MarkAsMailboxReadLoading());
      onProgressController.add(Right(MarkAsMailboxReadLoading()));

      final listEmails = await _mailboxRepository.markAsMailboxRead(
          accountId,
          mailboxId,
          totalEmailUnread,
          onProgressController);

      if (totalEmailUnread == listEmails.length) {
        yield Right(MarkAsMailboxReadAllSuccess(mailboxName));
      } else if (listEmails.isNotEmpty) {
        yield Right(MarkAsMailboxReadHasSomeEmailFailure(mailboxName, listEmails.length));
      } else {
        yield Left(MarkAsMailboxReadAllFailure());
      }
    } catch (e) {
      yield Left(MarkAsMailboxReadFailure(e));
    }
  }
}