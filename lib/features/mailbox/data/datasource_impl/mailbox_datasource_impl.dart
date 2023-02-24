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
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_api.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_isolate_worker.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/subscribe_multiple_mailbox_request.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class MailboxDataSourceImpl extends MailboxDataSource {

  final MailboxAPI mailboxAPI;
  final MailboxIsolateWorker _mailboxIsolateWorker;
  final ExceptionThrower _exceptionThrower;

  MailboxDataSourceImpl(this.mailboxAPI, this._mailboxIsolateWorker, this._exceptionThrower);

  @override
  Future<MailboxResponse> getAllMailbox(Session session, AccountId accountId, {Properties? properties}) {
    return Future.sync(() async {
      return await mailboxAPI.getAllMailbox(session, accountId, properties: properties);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<MailboxChangeResponse> getChanges(Session session, AccountId accountId, State sinceState) {
    return Future.sync(() async {
      return await mailboxAPI.getChanges(session, accountId, sinceState);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> update({List<Mailbox>? updated, List<Mailbox>? created, List<MailboxId>? destroyed}) {
    throw UnimplementedError();
  }

  @override
  Future<List<Mailbox>> getAllMailboxCache() {
    throw UnimplementedError();
  }

  @override
  Future<Mailbox?> createNewMailbox(AccountId accountId, CreateNewMailboxRequest newMailboxRequest) {
    return Future.sync(() async {
      return await mailboxAPI.createNewMailbox(accountId, newMailboxRequest);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<Map<Id,SetError>> deleteMultipleMailbox(Session session, AccountId accountId, List<MailboxId> mailboxIds) {
    return Future.sync(() async {
      return await mailboxAPI.deleteMultipleMailbox(session, accountId, mailboxIds);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> renameMailbox(AccountId accountId, RenameMailboxRequest request) {
    return Future.sync(() async {
      return await mailboxAPI.renameMailbox(accountId, request);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> moveMailbox(AccountId accountId, MoveMailboxRequest request) {
    return Future.sync(() async {
      return await mailboxAPI.moveMailbox(accountId, request);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<Email>> markAsMailboxRead(
      AccountId accountId,
      MailboxId mailboxId,
      int totalEmailUnread,
      StreamController<dartz.Either<Failure, Success>> onProgressController) {
    return Future.sync(() async {
      return await _mailboxIsolateWorker.markAsMailboxRead(
          accountId,
          mailboxId,
          totalEmailUnread,
          onProgressController);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<bool> subscribeMailbox(AccountId accountId, SubscribeMailboxRequest request) {
    return Future.sync(() async {
      return await mailboxAPI.subscribeMailbox(accountId, request);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<MailboxId>> subscribeMultipleMailbox(AccountId accountId, SubscribeMultipleMailboxRequest subscribeRequest) {
    return Future.sync(() async {
      return await mailboxAPI.subscribeMultipleMailbox(accountId, subscribeRequest);
    }).catchError(_exceptionThrower.throwException);
  }
}