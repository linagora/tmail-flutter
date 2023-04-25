
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/caching/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/list_mailbox_cache_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/list_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/list_mailbox_id_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/mailbox_cache_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/spam_report_exception.dart';

class MailboxCacheManager {

  final MailboxCacheClient _mailboxCacheClient;

  MailboxCacheManager(this._mailboxCacheClient);

  Future<List<Mailbox>> getAllMailbox(AccountId accountId) async {
    final mailboxCacheList = await _mailboxCacheClient.getListByCollectionId(accountId.asString);
    return mailboxCacheList.toMailboxList();
  }

  Future<void> update(
    AccountId accountId, {
    List<Mailbox>? updated,
    List<Mailbox>? created,
    List<MailboxId>? destroyed
  }) async {
    final mailboxCacheExist = await _mailboxCacheClient.isExistTable();
    if (mailboxCacheExist) {
      final updatedCacheMailboxes = updated?.toMapCache(accountId) ?? {};
      final createdCacheMailboxes = created?.toMapCache(accountId) ?? {};
      final destroyedCacheMailboxes = destroyed?.toCacheKeyList(accountId) ?? [];

      await Future.wait([
        _mailboxCacheClient.updateMultipleItem(updatedCacheMailboxes),
        _mailboxCacheClient.insertMultipleItem(createdCacheMailboxes),
        _mailboxCacheClient.deleteMultipleItem(destroyedCacheMailboxes)
      ]);
    } else {
      final createdCacheMailboxes = created?.toMapCache(accountId) ?? {};
      await _mailboxCacheClient.insertMultipleItem(createdCacheMailboxes);
    }
  }

  Future<Mailbox> getSpamMailbox() async {
    final mailboxCachedList = await _mailboxCacheClient.getAll();
    final listSpamMailboxCached = mailboxCachedList
      .map((mailboxCached) => mailboxCached.toMailbox())
      .where((mailbox) => mailbox.role == PresentationMailbox.roleSpam)
      .toList();

    if (listSpamMailboxCached.isNotEmpty) {
      return listSpamMailboxCached.first;
    } else {
      throw NotFoundSpamMailboxCachedException();
    }
  }
}