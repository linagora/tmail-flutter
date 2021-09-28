import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/get/get_mailbox_response.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache_response.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';

abstract class MailboxDataSource {
  Future<GetMailboxResponse?> getAllMailbox(AccountId accountId, {Properties? properties});

  Future<MailboxChangeResponse> getChanges(AccountId accountId, State sinceState);

  Future<MailboxCacheResponse> getAllMailboxCache();

  Future<MailboxChangeResponse> combineMailboxCache(MailboxChangeResponse mailboxChangeResponse, List<Mailbox> mailboxList);

  Future<void> asyncUpdateCache(MailboxChangeResponse mailboxChangeResponse);
}