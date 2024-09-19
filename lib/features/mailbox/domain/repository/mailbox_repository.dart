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
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/get_mailbox_by_role_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';

abstract class MailboxRepository {
  Stream<MailboxResponse> getAllMailbox(Session session, AccountId accountId, {Properties? properties});

  Stream<MailboxResponse> refresh(Session session, AccountId accountId, State currentState, {Properties? properties});

  Future<Mailbox?> createNewMailbox(Session session, AccountId accountId, CreateNewMailboxRequest newMailboxRequest);

  Future<Map<Id,SetError>> deleteMultipleMailbox(Session session, AccountId accountId, List<MailboxId> mailboxIds);

  Future<bool> renameMailbox(Session session, AccountId accountId, RenameMailboxRequest request);

  Future<List<Email>> markAsMailboxRead(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmailUnread,
    StreamController<dartz.Either<Failure, Success>> onProgressController);

  Future<bool> moveMailbox(Session session, AccountId accountId, MoveMailboxRequest request);

  Future<State?> getMailboxState(Session session, AccountId accountId);

  Future<bool> subscribeMailbox(Session session, AccountId accountId, SubscribeMailboxRequest request);

  Future<List<MailboxId>> subscribeMultipleMailbox(Session session, AccountId accountId, SubscribeMultipleMailboxRequest subscribeRequest);

  Future<List<Mailbox>> createDefaultMailbox(Session session, AccountId accountId, List<Role> listRole);

  Future<void> setRoleDefaultMailbox(Session session, AccountId accountId, List<Mailbox> listMailbox);

  Future<GetMailboxByRoleResponse> getMailboxByRole(Session session, AccountId accountId, Role role, {UnsignedInt? limit});

  Future<List<MailboxId>> getListMailboxById(Session session, AccountId accountId, List<MailboxId> mailboxIds);
}