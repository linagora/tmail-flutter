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
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/move_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class MailboxCacheDataSourceImpl extends MailboxDataSource {

  final MailboxCacheManager _mailboxCacheManager;
  final ExceptionThrower _exceptionThrower;

  MailboxCacheDataSourceImpl(this._mailboxCacheManager, this._exceptionThrower);

  @override
  Future<MailboxResponse> getAllMailbox(AccountId accountId, {Properties? properties}) {
    throw UnimplementedError();
  }

  @override
  Future<MailboxChangeResponse> getChanges(AccountId accountId, State sinceState) {
    throw UnimplementedError();
  }

  @override
  Future<void> update({List<Mailbox>? updated, List<Mailbox>? created, List<MailboxId>? destroyed}) {
    return Future.sync(() async {
      return await _mailboxCacheManager.update(updated: updated, created: created, destroyed: destroyed);
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<List<Mailbox>> getAllMailboxCache() {
    return Future.sync(() async {
      final listMailboxes = await _mailboxCacheManager.getAllMailbox();
      return listMailboxes;
    }).catchError((error) {
      _exceptionThrower.throwException(error);
    });
  }

  @override
  Future<Mailbox?> createNewMailbox(AccountId accountId, CreateNewMailboxRequest newMailboxRequest) {
    throw UnimplementedError();
  }

  @override
  Future<dartz.Tuple2<bool,Map<Id,SetError>>> deleteMultipleMailbox(Session session, AccountId accountId, List<MailboxId> mailboxIds) {
    throw UnimplementedError();
  }

  @override
  Future<bool> renameMailbox(AccountId accountId, RenameMailboxRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<bool> moveMailbox(AccountId accountId, MoveMailboxRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<List<Email>> markAsMailboxRead(
      AccountId accountId,
      MailboxId mailboxId,
      int totalEmailUnread,
      StreamController<dartz.Either<Failure, Success>> onProgressController) {
    throw UnimplementedError();
  }
}