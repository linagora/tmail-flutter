import 'dart:async';

import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class LocalThreadDataSourceImpl extends ThreadDataSource {

  final EmailCacheManager _emailCacheManager;
  final ExceptionThrower _exceptionThrower;

  LocalThreadDataSourceImpl(this._emailCacheManager, this._exceptionThrower);

  @override
  Future<EmailsResponse> getAllEmail(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties
    }
  ) {
    throw UnimplementedError();
  }

  @override
  Future<EmailChangeResponse> getChanges(
    Session session,
    AccountId accountId,
    State sinceState,
    {
      Properties? propertiesCreated,
      Properties? propertiesUpdated
    }
  ) {
    throw UnimplementedError();
  }

  @override
  Future<List<Email>> getAllEmailCache({
    MailboxId? inMailboxId,
    Set<Comparator>? sort,
    FilterMessageOption? filterOption,
    UnsignedInt? limit
  }) {
    return Future.sync(() async {
      return await _emailCacheManager.getAllEmail(
        inMailboxId: inMailboxId,
        sort: sort,
        filterOption: filterOption ?? FilterMessageOption.all,
        limit: limit);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> update(
    AccountId accountId, {
    List<Email>? updated,
    List<Email>? created,
    List<EmailId>? destroyed
  }) {
    return Future.sync(() async {
      return await _emailCacheManager.update(
        accountId,
        updated: updated,
        created: created,
        destroyed: destroyed);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<EmailId>> emptyTrashFolder(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    Future<void> Function(List<EmailId>? newDestroyed) updateDestroyedEmailCache
  ) {
    throw UnimplementedError();
  }

  @override
  Future<PresentationEmail> getEmailById(Session session, AccountId accountId, EmailId emailId, {Properties? properties}) {
    throw UnimplementedError();
  }
}