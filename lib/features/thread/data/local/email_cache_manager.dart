import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:model/model.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/caching/email_cache_client.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/email_cleanup_rule.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_cache_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/list_email_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/list_email_id_extension.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class EmailCacheManager {

  final EmailCacheClient _emailCacheClient;

  EmailCacheManager(this._emailCacheClient);

  Future<List<Email>> getAllEmail({
    MailboxId? inMailboxId,
    Set<Comparator>? sort,
    UnsignedInt? limit,
    FilterMessageOption filterOption = FilterMessageOption.all
  }) async {
    final emailCacheList = inMailboxId != null
      ? await _emailCacheClient.getListEmailCacheByMailboxId(inMailboxId)
      : await _emailCacheClient.getAll();
    final emailList = emailCacheList
        .map((emailCache) => emailCache.toEmail())
        .where((email) => filterOption.filterEmail(email))
        .toList();
    if (sort != null) {
      for (var comparator in sort) {
        emailList.sortBy(comparator);
      }
    }

    if (limit != null && emailList.length > limit.value.toInt()) {
      return emailList.getRange(0, limit.value.toInt()).toList();
    }
    return emailList;
  }

  Future<void> update(
    AccountId accountId, {
    List<Email>? updated,
    List<Email>? created,
    List<EmailId>? destroyed
  }) async {
    final emailCacheExist = await _emailCacheClient.isExistTable();
    if (emailCacheExist) {
      final updatedCacheEmails = updated?.toMapCache(accountId) ?? {};
      final createdCacheEmails = created?.toMapCache(accountId) ?? {};
      final destroyedCacheEmails = destroyed?.toCacheKeyList(accountId) ?? [];

      await Future.wait([
        _emailCacheClient.updateMultipleItem(updatedCacheEmails),
        _emailCacheClient.insertMultipleItem(createdCacheEmails),
        _emailCacheClient.deleteMultipleItem(destroyedCacheEmails)
      ]);
    } else {
      final createdCacheEmails = created?.toMapCache(accountId) ?? {};
      await _emailCacheClient.insertMultipleItem(createdCacheEmails);
    }
  }

  Future<void> clean(EmailCleanupRule cleanupRule) async {
    final emailCacheExist = await _emailCacheClient.isExistTable();
    if (emailCacheExist) {
      final listEmailCache = await _emailCacheClient.getAll();
      final listEmailIdCacheExpire = listEmailCache
        .where((emailCache) => emailCache.expireTimeCaching(cleanupRule))
        .map((emailCache) => emailCache.id)
        .toList();
      await _emailCacheClient.deleteMultipleItem(listEmailIdCacheExpire);
    }
  }
}