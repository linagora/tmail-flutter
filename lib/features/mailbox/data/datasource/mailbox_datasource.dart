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
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/get_mailbox_by_role_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/jmap_mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_right_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';

abstract class MailboxDataSource {
  Future<JmapMailboxResponse> getAllMailbox(Session session, AccountId accountId, {Properties? properties});

  Future<List<Mailbox>> getAllMailboxCache(AccountId accountId, UserName userName);

  Future<MailboxChangeResponse> getChanges(Session session, AccountId accountId, State sinceState, {Properties? properties});

  Future<void> update(AccountId accountId, UserName userName, {List<Mailbox>? updated, List<Mailbox>? created, List<MailboxId>? destroyed});

  Future<Mailbox?> createNewMailbox(Session session, AccountId accountId, CreateNewMailboxRequest newMailboxRequest);

  Future<Map<Id,SetError>> deleteMultipleMailbox(Session session, AccountId accountId, List<MailboxId> mailboxIds);

  Future<bool> renameMailbox(Session session, AccountId accountId, RenameMailboxRequest request);

  Future<bool> moveMailbox(Session session, AccountId accountId, MoveMailboxRequest request);

  Future<List<Email>> markAsMailboxRead(
      Session session,
      AccountId accountId,
      MailboxId mailboxId,
      int totalEmailUnread,
      StreamController<dartz.Either<Failure, Success>> onProgressController);

  Future<bool> subscribeMailbox(Session session, AccountId accountId, SubscribeMailboxRequest request);

  Future<List<MailboxId>> subscribeMultipleMailbox(Session session, AccountId accountId, SubscribeMultipleMailboxRequest subscribeRequest);

  Future<bool> handleMailboxRightRequest(Session session, AccountId accountId, MailboxRightRequest request);

  Future<List<Mailbox>> createDefaultMailbox(Session session, AccountId accountId, List<Role> listRole);

  Future<void> setRoleDefaultMailbox(Session session, AccountId accountId, List<Mailbox> listMailbox);

  Future<GetMailboxByRoleResponse> getMailboxByRole(Session session, AccountId accountId, Role role);

  Future<void> clearAllMailboxCache(AccountId accountId, UserName userName);
}