import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';

abstract class MailboxRepository {
  Stream<MailboxResponse> getAllMailbox(AccountId accountId, {Properties? properties});

  Stream<MailboxResponse> refresh(AccountId accountId, State currentState);

  Future<Mailbox?> createNewMailbox(AccountId accountId, CreateNewMailboxRequest newMailboxRequest);

  Future<Map<Id,SetError>> deleteMultipleMailbox(Session session, AccountId accountId, List<MailboxId> mailboxIds);

  Future<bool> renameMailbox(AccountId accountId, RenameMailboxRequest request);

  Future<List<Email>> markAsMailboxRead(
      AccountId accountId,
      MailboxId mailboxId,
      int totalEmailUnread,
      StreamController<dartz.Either<Failure, Success>> onProgressController);

  Future<bool> moveMailbox(AccountId accountId, MoveMailboxRequest request);

  Future<State?> getMailboxState();
}