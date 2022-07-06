import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';

abstract class MailboxDataSource {
  Future<MailboxResponse> getAllMailbox(AccountId accountId, {Properties? properties});

  Future<List<Mailbox>> getAllMailboxCache();

  Future<MailboxChangeResponse> getChanges(AccountId accountId, State sinceState);

  Future<void> update({List<Mailbox>? updated, List<Mailbox>? created, List<MailboxId>? destroyed});

  Future<Mailbox?> createNewMailbox(AccountId accountId, CreateNewMailboxRequest newMailboxRequest);

  Future<bool> deleteMultipleMailbox(Session session, AccountId accountId, List<MailboxId> mailboxIds);

  Future<bool> renameMailbox(AccountId accountId, RenameMailboxRequest request);

  Future<bool> moveMailbox(AccountId accountId, MoveMailboxRequest request);

  Future<List<Email>> markAsMailboxRead(
      AccountId accountId,
      MailboxId mailboxId,
      int totalEmailUnread,
      StreamController<dartz.Either<Failure, Success>> onProgressController);
}