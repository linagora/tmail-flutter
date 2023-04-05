
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/caching/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/list_mailbox_cache_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/mailbox_cache_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/spam_report_exception.dart';

class MailboxCacheManager {

  final MailboxCacheClient _mailboxCacheClient;

  MailboxCacheManager(this._mailboxCacheClient);

  Future<List<Mailbox>> getAllMailbox() async {
    final mailboxCacheList = await _mailboxCacheClient.getAll();
    final mailboxList = mailboxCacheList.map((mailboxCache) => mailboxCache.toMailbox()).toList();
    return mailboxList;
  }

  Future<void> update({List<Mailbox>? updated, List<Mailbox>? created, List<MailboxId>? destroyed}) async {
    final mailboxCacheExist = await _mailboxCacheClient.isExistTable();
    if (mailboxCacheExist) {
      final updatedCacheMailboxes = updated
          ?.map((mailbox) => mailbox.toMailboxCache()).toList() ?? <MailboxCache>[];
      final createdCacheMailboxes = created
          ?.map((mailbox) => mailbox.toMailboxCache()).toList() ?? <MailboxCache>[];
      final destroyedCacheMailboxes = destroyed
          ?.map((mailboxId) => mailboxId.id.value).toList() ?? <String>[];
      await Future.wait([
        _mailboxCacheClient.updateMultipleItem(updatedCacheMailboxes.toMap()),
        _mailboxCacheClient.insertMultipleItem(createdCacheMailboxes.toMap()),
        _mailboxCacheClient.deleteMultipleItem(destroyedCacheMailboxes)
      ]);
    } else {
      final createdCacheMailboxes = created
          ?.map((mailbox) => mailbox.toMailboxCache()).toList() ?? <MailboxCache>[];
      await _mailboxCacheClient.insertMultipleItem(createdCacheMailboxes.toMap());
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