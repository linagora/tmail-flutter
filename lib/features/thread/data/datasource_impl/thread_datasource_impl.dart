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
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_isolate_worker.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_emails_response.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class ThreadDataSourceImpl extends ThreadDataSource {

  final ThreadAPI threadAPI;
  final ThreadIsolateWorker _threadIsolateWorker;
  final ExceptionThrower _exceptionThrower;

  ThreadDataSourceImpl(
    this.threadAPI,
    this._threadIsolateWorker,
    this._exceptionThrower
  );

  @override
  Future<EmailsResponse> getAllEmail(
    Session session,
    AccountId accountId,
    {
      UnsignedInt? limit,
      int? position,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties,
    }
  ) {
    return Future.sync(() async {
      return await threadAPI.getAllEmail(
        session,
        accountId,
        limit: limit,
        position: position,
        sort: sort,
        filter: filter,
        properties: properties);
    }).catchError(_exceptionThrower.throwException);
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
      Properties? properties,
    }
  ) {
    return Future.sync(() async {
      return await threadAPI.searchEmails(
        session,
        accountId,
        limit: limit,
        position: position,
        sort: sort,
        filter: filter,
        properties: properties);
    }).catchError(_exceptionThrower.throwException);
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
    return Future.sync(() async {
      return await threadAPI.getChanges(
        session,
        accountId,
        sinceState,
        propertiesCreated: propertiesCreated,
        propertiesUpdated: propertiesUpdated);
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<Email>> getAllEmailCache(AccountId accountId, UserName userName, {MailboxId? inMailboxId, Set<Comparator>? sort, FilterMessageOption? filterOption, UnsignedInt? limit}) {
    throw UnimplementedError();
  }

  @override
  Future<void> update(AccountId accountId, UserName userName, {List<Email>? updated, List<Email>? created, List<EmailId>? destroyed}) {
    throw UnimplementedError();
  }

  @override
  Future<List<EmailId>> emptyMailboxFolder(
    Session session,
    AccountId accountId,
    MailboxId mailboxId,
    int totalEmails,
    StreamController<dartz.Either<Failure, Success>> onProgressController
  ) {
    return Future.sync(() async {
      return await _threadIsolateWorker.emptyMailboxFolder(
        session,
        accountId,
        mailboxId,
        totalEmails,
        onProgressController
      );
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<PresentationEmail> getEmailById(Session session, AccountId accountId, EmailId emailId, {Properties? properties}) {
    return Future.sync(() async {
      final email = await threadAPI.getEmailById(session, accountId, emailId, properties: properties);
      return email.toPresentationEmail();
    }).catchError(_exceptionThrower.throwException);
  }
}