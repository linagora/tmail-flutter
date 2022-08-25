import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/thread_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/local/email_cache_manager.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_change_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/email_response.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class LocalThreadDataSourceImpl extends ThreadDataSource {

  final EmailCacheManager _emailCacheManager;

  LocalThreadDataSourceImpl(this._emailCacheManager);

  @override
  Future<EmailsResponse> getAllEmail(
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
  Future<List<Email>> getAllEmailCache({MailboxId? inMailboxId, Set<Comparator>? sort, FilterMessageOption? filterOption}) {
    return Future.sync(() async {
      return await _emailCacheManager.getAllEmail(inMailboxId: inMailboxId, sort: sort, filterOption: filterOption ?? FilterMessageOption.all);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> update({List<Email>? updated, List<Email>? created, List<EmailId>? destroyed}) {
    return Future.sync(() async {
      return await _emailCacheManager.update(updated: updated, created: created, destroyed: destroyed);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<EmailId>> emptyTrashFolder(AccountId accountId, MailboxId mailboxId, Future<void> Function(State state) updateState, Future<void> Function(List<EmailId>? newDestroyed) updateDestroyedEmailCache) {
    throw UnimplementedError();
  }
}