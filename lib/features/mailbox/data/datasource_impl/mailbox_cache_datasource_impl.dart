import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/get/get_mailbox_response.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/datasource/mailbox_datasource.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache_response.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';
import 'package:tmail_ui_user/features/mailbox/data/network/mailbox_cache_manager.dart';

class MailboxCacheDataSourceImpl extends MailboxDataSource {

  final MailboxCacheManager _mailboxCacheManager;

  MailboxCacheDataSourceImpl(this._mailboxCacheManager);

  @override
  Future<GetMailboxResponse?> getAllMailbox(AccountId accountId, {Properties? properties}) {
    throw UnimplementedError();
  }

  @override
  Future<MailboxCacheResponse> getAllMailboxCache() {
    return Future.sync(() async {
      return await _mailboxCacheManager.getAllMailbox();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> asyncUpdateCache(MailboxChangeResponse mailboxChangeResponse) {
    return Future.sync(() async {
      return await _mailboxCacheManager.asyncUpdateCache(mailboxChangeResponse);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<MailboxChangeResponse> getChanges(AccountId accountId, State sinceState) {
    throw UnimplementedError();
  }

  @override
  Future<MailboxChangeResponse> combineMailboxCache(MailboxChangeResponse mailboxChangeResponse, List<Mailbox> mailboxList) {
    return Future.sync(() async {
      return await _mailboxCacheManager.combineMailboxCache(mailboxChangeResponse, mailboxList);
    }).catchError((error) {
      throw error;
    });
  }
}