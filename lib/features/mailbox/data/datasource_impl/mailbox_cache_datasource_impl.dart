import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_response.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/rename_mailbox_request.dart';

class MailboxCacheDataSourceImpl extends MailboxDataSource {

  final MailboxCacheManager _mailboxCacheManager;

  MailboxCacheDataSourceImpl(this._mailboxCacheManager);

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
      throw error;
    });
  }

  @override
  Future<List<Mailbox>> getAllMailboxCache() {
    return Future.sync(() async {
      final listMailboxes = await _mailboxCacheManager.getAllMailbox();
      return listMailboxes;
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<Mailbox?> createNewMailbox(AccountId accountId, CreateNewMailboxRequest newMailboxRequest) {
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteMultipleMailbox(Session session, AccountId accountId, List<MailboxId> mailboxIds) {
    throw UnimplementedError();
  }

  @override
  Future<bool> renameMailbox(AccountId accountId, RenameMailboxRequest request) {
    throw UnimplementedError();
  }
}