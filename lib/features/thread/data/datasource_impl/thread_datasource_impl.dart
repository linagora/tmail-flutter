import 'dart:async';

import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_isolate_worker.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/data/network/thread_api.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class ThreadDataSourceImpl extends ThreadDataSource {

  final ThreadAPI threadAPI;
  final ThreadIsolateWorker _threadIsolateWorker;

  ThreadDataSourceImpl(this.threadAPI, this._threadIsolateWorker);

  @override
  Future<EmailsResponse> getAllEmail(
    AccountId accountId,
    {
      UnsignedInt? limit,
      Set<Comparator>? sort,
      Filter? filter,
      Properties? properties,
    }
  ) {
    return Future.sync(() async {
      return await threadAPI.getAllEmail(
        accountId,
        limit: limit,
        sort: sort,
        filter: filter,
        properties: properties);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<EmailChangeResponse> getChanges(
      AccountId accountId,
      State sinceState,
      {
        Properties? propertiesCreated,
        Properties? propertiesUpdated
      }
  ) {
    return Future.sync(() async {
      return await threadAPI.getChanges(
        accountId,
        sinceState,
        propertiesCreated: propertiesCreated,
        propertiesUpdated: propertiesUpdated);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<Email>> getAllEmailCache({MailboxId? inMailboxId, Set<Comparator>? sort, FilterMessageOption? filterOption}) {
    throw UnimplementedError();
  }

  @override
  Future<void> update({List<Email>? updated, List<Email>? created, List<EmailId>? destroyed}) {
    throw UnimplementedError();
  }

  @override
  Future<List<EmailId>> emptyTrashFolder(AccountId accountId, MailboxId mailboxId, Future<void> Function(List<EmailId>? newDestroyed) updateDestroyedEmailCache) {
    return Future.sync(() async {
      return await _threadIsolateWorker.emptyTrashFolder(
          accountId,
          mailboxId,
          updateDestroyedEmailCache,
      );
    }).catchError((error) {
      throw error;
    });
  }
}