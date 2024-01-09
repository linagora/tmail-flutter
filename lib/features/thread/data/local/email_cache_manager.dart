import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/caching/clients/email_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/email_cleanup_rule.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_cache_exceptions.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_cache_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/list_email_cache_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/list_email_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/list_email_id_extension.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class EmailCacheManager {

  final EmailCacheClient _emailCacheClient;

  EmailCacheManager(this._emailCacheClient);

  Future<List<Email>> getAllEmail(
    AccountId accountId,
    UserName userName, {
    MailboxId? inMailboxId,
    Set<Comparator>? sort,
    UnsignedInt? limit,
    FilterMessageOption filterOption = FilterMessageOption.all
  }) async {
    final emailCacheList = await _emailCacheClient.getListByTupleKey(accountId.asString, userName.value);
    final emailList = emailCacheList
      .toEmailList()
      .where((email) => _filterEmailByMailbox(email, filterOption, inMailboxId))
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

  bool _filterEmailByMailbox(Email email, FilterMessageOption option, MailboxId? inMailboxId) {
    if (inMailboxId != null) {
      return email.belongTo(inMailboxId) && option.filterEmail(email);
    } else {
      return option.filterEmail(email);
    }
  }

  Future<void> update(
    AccountId accountId,
    UserName userName, {
    List<Email>? updated,
    List<Email>? created,
    List<EmailId>? destroyed
  }) async {
    final emailCacheExist = await _emailCacheClient.isExistTable();
    if (emailCacheExist) {
      final updatedCacheEmails = updated?.toMapCache(accountId, userName) ?? {};
      final createdCacheEmails = created?.toMapCache(accountId, userName) ?? {};
      final destroyedCacheEmails = destroyed?.toCacheKeyList(accountId, userName) ?? [];

      await Future.wait([
        _emailCacheClient.updateMultipleItem(updatedCacheEmails),
        _emailCacheClient.insertMultipleItem(createdCacheEmails),
        _emailCacheClient.deleteMultipleItem(destroyedCacheEmails)
      ]);
    } else {
      final createdCacheEmails = created?.toMapCache(accountId, userName) ?? {};
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

  Future<void> storeEmail(AccountId accountId, UserName userName, EmailCache emailCache) {
    final keyCache = TupleKey(accountId.asString, userName.value, emailCache.id).encodeKey;
    return _emailCacheClient.insertItem(keyCache, emailCache);
  }

  Future<EmailCache> getStoredEmail(AccountId accountId, UserName userName, EmailId emailId) async {
    final keyCache = TupleKey(accountId.asString, userName.value, emailId.asString).encodeKey;
    final emailCache = await _emailCacheClient.getItem(keyCache, needToReopen: true);
    if (emailCache != null) {
      return emailCache;
    } else {
      throw NotFoundStoredEmailException();
    }
  }
}