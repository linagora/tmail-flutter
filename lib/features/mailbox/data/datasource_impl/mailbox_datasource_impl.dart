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
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_isolate_worker.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/get_mailbox_by_role_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/jmap_mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_right_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class MailboxDataSourceImpl extends MailboxDataSource {

  final MailboxAPI mailboxAPI;
  final MailboxIsolateWorker _mailboxIsolateWorker;
  final ExceptionThrower _exceptionThrower;

  MailboxDataSourceImpl(this.mailboxAPI, this._mailboxIsolateWorker, this._exceptionThrower);

  @override
  Future<JmapMailboxResponse> getAllMailbox(Session session, AccountId accountId, {Properties? properties}) {
    return Future.sync(() async {
      return await mailboxAPI.getAllMailbox(session, accountId, properties: properties);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<MailboxChangeResponse> getChanges(Session session, AccountId accountId, State sinceState, {Properties? properties}) {
    return Future.sync(() async {
      return await mailboxAPI.getChanges(session, accountId, sinceState, properties: properties);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> update(AccountId accountId, UserName userName, {List<Mailbox>? updated, List<Mailbox>? created, List<MailboxId>? destroyed}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Mailbox>> getAllMailboxCache(AccountId accountId, UserName userName) {
    throw UnimplementedError();
  }

  @override
  Future<Mailbox?> createNewMailbox(Session session, AccountId accountId, CreateNewMailboxRequest newMailboxRequest) {
    return Future.sync(() async {
      return await mailboxAPI.createNewMailbox(session, accountId, newMailboxRequest);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Map<Id,SetError>> deleteMultipleMailbox(Session session, AccountId accountId, List<MailboxId> mailboxIds) {
    return Future.sync(() async {
      return await mailboxAPI.deleteMultipleMailbox(session, accountId, mailboxIds);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> renameMailbox(Session session, AccountId accountId, RenameMailboxRequest request) {
    return Future.sync(() async {
      return await mailboxAPI.renameMailbox(session, accountId, request);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> moveMailbox(Session session, AccountId accountId, MoveMailboxRequest request) {
    return Future.sync(() async {
      return await mailboxAPI.moveMailbox(session, accountId, request);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<Email>> markAsMailboxRead(
      Session session,
      AccountId accountId,
      MailboxId mailboxId,
      int totalEmailUnread,
      StreamController<dartz.Either<Failure, Success>> onProgressController) {
    return Future.sync(() async {
      return await _mailboxIsolateWorker.markAsMailboxRead(
          session,
          accountId,
          mailboxId,
          totalEmailUnread,
          onProgressController);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> subscribeMailbox(Session session, AccountId accountId, SubscribeMailboxRequest request) {
    return Future.sync(() async {
      return await mailboxAPI.subscribeMailbox(session, accountId, request);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<MailboxId>> subscribeMultipleMailbox(
    Session session,
    AccountId accountId,
    SubscribeMultipleMailboxRequest subscribeRequest
  ) {
    return Future.sync(() async {
      return await mailboxAPI.subscribeMultipleMailbox(session, accountId, subscribeRequest);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> handleMailboxRightRequest(Session session, AccountId accountId, MailboxRightRequest request) {
    return Future.sync(() async {
      return await mailboxAPI.handleMailboxRightRequest(session, accountId, request);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<Mailbox>> createDefaultMailbox(Session session, AccountId accountId, List<Role> listRole) {
    return Future.sync(() async {
      return await mailboxAPI.createDefaultMailbox(session, accountId, listRole);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> setRoleDefaultMailbox(Session session, AccountId accountId, List<Mailbox> listMailbox) {
    return Future.sync(() async {
      return await mailboxAPI.setRoleDefaultMailbox(session, accountId, listMailbox);
    }).catchError(_exceptionThrower.throwException);
  }
  
  @override
  Future<GetMailboxByRoleResponse> getMailboxByRole(Session session, AccountId accountId, Role role, {UnsignedInt? limit}) {
    return Future.sync(() async {
      return await mailboxAPI.getMailboxByRole(session, accountId, role);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> clearAllMailboxCache(AccountId accountId, UserName userName) {
    throw UnimplementedError();
  }
}