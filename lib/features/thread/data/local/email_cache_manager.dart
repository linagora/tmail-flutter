import 'package:core/utils/app_logger.dart';
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
    final nestedKey = TupleKey(accountId.asString, userName.value).encodeKey;
    log('EmailCacheManager::getAllEmail()::nestedKey = $nestedKey');
    final emailCacheList = await _emailCacheClient.getListByNestedKey(nestedKey);
    log('EmailCacheManager::getAllEmail()::emailCacheList length = ${emailCacheList.length} ================');
    final emailList = emailCacheList
      .toEmailList()
      .where((email) => _filterEmailByMailbox(email, filterOption, inMailboxId))
      .toList();

    log('DATPH EmailCacheManager::getAllEmail(): emailList length ${emailList.length} ================');
    for (final emailCache in emailCacheList) {
      log('DATPH EmailCacheManager::getAllEmail(): ${emailCache.id} - ${emailCache.subject} - ${emailCache.keywords} - ${emailCache.mailboxIds}');
    }
    log('DATPH EmailCacheManager::getAllEmail(): ================');

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
    log('EmailCacheManager::_filterEmailByMailbox()::inMailboxId = $inMailboxId | option = $option | email = ${email.id} - ${email.subject} - ${email.keywords} - ${email.mailboxIds}');
    bool isBelongToMailbox = inMailboxId != null
        ? email.belongTo(inMailboxId) && option.filterEmail(email)
        : option.filterEmail(email);
    log('EmailCacheManager::_filterEmailByMailbox()::isBelongToMailbox = $isBelongToMailbox');
    return isBelongToMailbox;
  }

  Future<void> update(
    AccountId accountId,
    UserName userName, {
    List<Email>? updated,
    List<Email>? created,
    List<EmailId>? destroyed
  }) async {
    log('EmailCacheManager::update() updated: ${updated?.length} created: ${created?.length} destroyed: ${destroyed?.length}');
    if (created?.isNotEmpty == true) {
      final createdCacheEmails = created!.toMapCache(accountId, userName);
      await _emailCacheClient.insertMultipleItem(createdCacheEmails);
    }

    if (updated?.isNotEmpty == true) {
      final updatedCacheEmails = updated!.toMapCache(accountId, userName);
      await _emailCacheClient.updateMultipleItem(updatedCacheEmails);
    }

    if (destroyed?.isNotEmpty == true) {
      final destroyedCacheEmails = destroyed!.toCacheKeyList(accountId, userName);
      await _emailCacheClient.deleteMultipleItem(destroyedCacheEmails);
    }
    log('EmailCacheManager::update() start to get all in email cache ================');
    final listEmailCache = await _emailCacheClient.getAll();
    log('EmailCacheManager::update() cached length = ${listEmailCache.length} ================');
    log('EmailCacheManager::update() end to get all in email cache ================');
  }

  Future<void> clean(EmailCleanupRule cleanupRule) async {
      final listEmailCache = await _emailCacheClient.getAll();
      log('EmailCacheManager::clean():: start to get all in email cache length = ${listEmailCache.length} ================');
      final listEmailIdCacheExpire = listEmailCache
        .where((emailCache) => emailCache.expireTimeCaching(cleanupRule))
        .map((emailCache) => emailCache.id)
        .toList();
      log('EmailCacheManager::clean():: listEmailIdCacheExpire length = ${listEmailIdCacheExpire.length} ================');
      log('EmailCacheManager::clean():: listEmailIdCacheExpire = $listEmailIdCacheExpire ================');
      await _emailCacheClient.deleteMultipleItem(listEmailIdCacheExpire);
      log('EmailCacheManager::clean() end deleteMultipleItem =================');
  }

  Future<void> storeEmail(AccountId accountId, UserName userName, EmailCache emailCache) {
    final keyCache = TupleKey(emailCache.id, accountId.asString, userName.value).encodeKey;
    log('EmailCacheManager::storeEmail()::keyCache = $keyCache | ${emailCache.id} - ${emailCache.subject} - ${emailCache.keywords} - ${emailCache.mailboxIds}');
    return _emailCacheClient.insertItem(keyCache, emailCache);
  }

  Future<void> storeMultipleEmails(AccountId accountId, UserName userName, List<EmailCache> emailsCache) async {
    final emailsToCache = Map.fromEntries(emailsCache.map(
      (emailCache) => MapEntry(
        TupleKey(emailCache.id, accountId.asString, userName.value).encodeKey,
        emailCache,
      ),
    ));
    log('EmailCacheManager::storeMultipleEmails()::emailsToCache length = ${emailsToCache.length} ================');
    for (final key in emailsToCache.keys) {
      final emailCache = emailsToCache[key];
      log('EmailCacheManager::storeMultipleEmails()::keyCache = $key - ${emailCache?.id} - ${emailCache?.subject} - ${emailCache?.keywords} - ${emailCache?.mailboxIds}');
    }
    await _emailCacheClient.insertMultipleItem(emailsToCache);
    log('EmailCacheManager::storeMultipleEmails() end insertMultipleItem =================');
  }

  Future<EmailCache> getStoredEmail(AccountId accountId, UserName userName, EmailId emailId) async {
    final keyCache = TupleKey(emailId.asString, accountId.asString, userName.value).encodeKey;
    log('EmailCacheManager::getStoredEmail()::keyCache = $keyCache');
    final emailCache = await _emailCacheClient.getItem(keyCache);
    log('EmailCacheManager::getStoredEmail()::${emailCache?.id} - ${emailCache?.subject} - ${emailCache?.keywords} - ${emailCache?.mailboxIds}');
    if (emailCache != null) {
      return emailCache;
    } else {
      throw NotFoundStoredEmailException();
    }
  }

  Future<List<EmailCache>> getMultipleStoredEmails(
    AccountId accountId,
    UserName userName,
    List<EmailId> emailIds,
  ) async {
    final keys = emailIds
      .map((emailId) => TupleKey(emailId.asString, accountId.asString, userName.value).encodeKey)
      .toList();
    log('EmailCacheManager::getMultipleStoredEmails()::keys length = ${keys.length} ================');
    for (final key in keys) {
      log('EmailCacheManager::getMultipleStoredEmails()::keyCache = $key');
    }
    final emails = await _emailCacheClient.getValuesByListKey(keys);
    log('EmailCacheManager::getMultipleStoredEmails()::emails length = ${emails.length} ================');
    return emails;
  }
}