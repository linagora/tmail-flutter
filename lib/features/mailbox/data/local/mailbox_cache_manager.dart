
import 'package:collection/collection.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/caching/clients/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/list_mailbox_cache_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/list_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/list_mailbox_id_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/spam_report_exception.dart';

class MailboxCacheManager {

  final MailboxCacheClient _mailboxCacheClient;

  MailboxCacheManager(this._mailboxCacheClient);

  Future<List<Mailbox>> getAllMailbox(AccountId accountId, UserName userName) async {
    final nestedKey = TupleKey(accountId.asString, userName.value).encodeKey;
    final mailboxCacheList = await _mailboxCacheClient.getListByNestedKey(nestedKey);
    return mailboxCacheList.toMailboxList();
  }

  Future<void> update(
    AccountId accountId,
    UserName userName, {
    List<Mailbox>? updated,
    List<Mailbox>? created,
    List<MailboxId>? destroyed
  }) async {
    final mailboxCacheExist = await _mailboxCacheClient.isExistTable();
    if (mailboxCacheExist) {
      final updatedCacheMailboxes = updated?.toMapCache(accountId, userName) ?? {};
      final createdCacheMailboxes = created?.toMapCache(accountId, userName) ?? {};
      final destroyedCacheMailboxes = destroyed?.toCacheKeyList(accountId, userName) ?? [];

      await Future.wait([
        _mailboxCacheClient.updateMultipleItem(updatedCacheMailboxes),
        _mailboxCacheClient.insertMultipleItem(createdCacheMailboxes),
        _mailboxCacheClient.deleteMultipleItem(destroyedCacheMailboxes)
      ]);
    } else {
      final createdCacheMailboxes = created?.toMapCache(accountId, userName) ?? {};
      await _mailboxCacheClient.insertMultipleItem(createdCacheMailboxes);
    }
    return Future.value();
  }

  Future<Mailbox> getSpamMailbox(AccountId accountId, UserName userName) async {
    final mailboxList = await getAllMailbox(accountId, userName);
    final spamMailbox = mailboxList.firstWhereOrNull((mailbox) => mailbox.role == PresentationMailbox.roleSpam);

    if (spamMailbox != null) {
      return spamMailbox;
    } else {
      throw NotFoundSpamMailboxCachedException();
    }
  }
}