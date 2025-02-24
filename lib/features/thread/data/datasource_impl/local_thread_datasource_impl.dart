import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_emails_response.dart';
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
      int? position,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties
    }
  ) {
    throw UnimplementedError();
  }

  @override
  Future<SearchEmailsResponse> searchEmails(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      int? position,
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
  Future<List<Email>> getAllEmailCache(
    AccountId accountId,
    UserName userName, {
    MailboxId? inMailboxId,
    Set<Comparator>? sort,
    FilterMessageOption? filterOption,
    UnsignedInt? limit
  }) {
    return Future.sync(() async {
      return await _emailCacheManager.getAllEmail(
        accountId,
        userName,
        inMailboxId: inMailboxId,
        sort: sort,
        filterOption: filterOption ?? FilterMessageOption.all,
        limit: limit);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<void> update(
    AccountId accountId,
    UserName userName, {
    List<Email>? updated,
    List<Email>? created,
    List<EmailId>? destroyed
  }) {
    return Future.sync(() async {
      return await _emailCacheManager.update(
        accountId,
        userName,
        updated: updated,
        created: created,
        destroyed: destroyed);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<EmailId>> emptyMailboxFolder(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController
  ) {
    throw UnimplementedError();
  }

  @override
  Future<PresentationEmail> getEmailById(Session session, AccountId accountId, EmailId emailId, {Properties? properties}) {
    throw UnimplementedError();
  }

  @override
  Future<List<EmailId>> markAllAsUnreadForSelectionAllEmails(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmailRead,
    StreamController<dartz.Either<Failure, Success>> onProgressController,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<List<EmailId>> moveAllSelectionAllEmails(
    Session session,
    AccountId accountId,
    MailboxId currentMailboxId,
    MailboxId destinationMailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController,
    {
      bool isDestinationSpamMailbox = false
    }
  ) {
    throw UnimplementedError();
  }

  @override
  Future<List<EmailId>> deleteAllPermanentlyEmails(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<List<EmailId>> markAllAsStarredForSelectionAllEmails(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController
  ) {
    throw UnimplementedError();
  }
}