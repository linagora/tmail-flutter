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
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/list_mailbox_extension.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/get_mailbox_by_role_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/jmap_mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_right_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class MailboxCacheDataSourceImpl extends MailboxDataSource {

  final MailboxCacheManager _mailboxCacheManager;
  final ExceptionThrower _exceptionThrower;

  MailboxCacheDataSourceImpl(this._mailboxCacheManager, this._exceptionThrower);

  @override
  Future<JmapMailboxResponse> getAllMailbox(Session session, AccountId accountId, {Properties? properties}) {
    throw UnimplementedError();
  }

  @override
  Future<MailboxChangeResponse> getChanges(Session session, AccountId accountId, State sinceState, {Properties? properties}) {
    throw UnimplementedError();
  }

  @override
  Future<void> update(AccountId accountId, UserName userName, {List<Mailbox>? updated, List<Mailbox>? created, List<MailboxId>? destroyed}) {
    return Future.sync(() async {
      return await _mailboxCacheManager.update(accountId, userName, updated: updated, created: created, destroyed: destroyed);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<Mailbox>> getAllMailboxCache(AccountId accountId, UserName userName) {
    return Future.sync(() async {
      final listMailboxes = await _mailboxCacheManager.getAllMailbox(accountId, userName);
      return listMailboxes;
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Mailbox?> createNewMailbox(Session session, AccountId accountId, CreateNewMailboxRequest newMailboxRequest) {
    throw UnimplementedError();
  }

  @override
  Future<Map<Id,SetError>> deleteMultipleMailbox(Session session, AccountId accountId, List<MailboxId> mailboxIds) {
    throw UnimplementedError();
  }

  @override
  Future<bool> renameMailbox(
    Session session,
    AccountId accountId,
    RenameMailboxRequest request,
  ) async {
    final cachedMailboxes = await getAllMailboxCache(accountId, session.username);
    final updatedMailbox = cachedMailboxes.findMailbox(request.mailboxId);
    if (updatedMailbox == null) return false;

    final updatedMailboxIndex = cachedMailboxes.indexOf(updatedMailbox);
    if (updatedMailboxIndex == -1) return false;
    
    cachedMailboxes[updatedMailboxIndex] = updatedMailbox.copyWith(name: request.newName);
    await update(
      accountId,
      session.username,
      updated: cachedMailboxes,
    );

    return true;
  }

  @override
  Future<bool> moveMailbox(Session session, AccountId accountId, MoveMailboxRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<List<EmailId>> markAsMailboxRead(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmailUnread,
    StreamController<dartz.Either<Failure, Success>> onProgressController,
  ) async {
    final mailboxes = await getAllMailboxCache(accountId, session.username);
    final updatedMailbox = mailboxes.findMailbox(mailboxId);
    if (updatedMailbox == null) return [];

    final updatedMailboxIndex = mailboxes.indexOf(updatedMailbox);
    if (updatedMailboxIndex == -1) return [];

    mailboxes[updatedMailboxIndex] = updatedMailbox.copyWith(
      unreadEmails: UnreadEmails(UnsignedInt(totalEmailUnread)),
    );
    await _mailboxCacheManager.update(
      accountId,
      session.username,
      updated: mailboxes,
    );

    return [];
  }

  @override
  Future<bool> subscribeMailbox(Session session, AccountId accountId, SubscribeMailboxRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<List<MailboxId>> subscribeMultipleMailbox(Session session, AccountId accountId, SubscribeMultipleMailboxRequest subscribeRequest) {
    throw UnimplementedError();
  }

  @override
  Future<bool> handleMailboxRightRequest(Session session, AccountId accountId, MailboxRightRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<(List<Mailbox> mailboxes, Map<Id, SetError> mapErrors)> createDefaultMailbox(Session session, AccountId accountId, Map<Id, Role> mapRoles) {
    throw UnimplementedError();
  }

  @override
  Future<(List<Mailbox> mailboxes, Map<Id, SetError> mapErrors)> setRoleDefaultMailbox(Session session, AccountId accountId, List<Mailbox> listMailbox) {
    throw UnimplementedError();
  }
  
  @override
  Future<GetMailboxByRoleResponse> getMailboxByRole(Session session, AccountId accountId, Role role, {UnsignedInt? limit}) {
    throw UnimplementedError();
  }

  @override
  Future<void> clearAllMailboxCache(AccountId accountId, UserName userName) {
    return Future.sync(() async {
      return await _mailboxCacheManager.deleteByKey(accountId, userName);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<UnsignedInt> clearMailbox(Session session, AccountId accountId, MailboxId mailboxId) {
    throw UnimplementedError();
  }
}