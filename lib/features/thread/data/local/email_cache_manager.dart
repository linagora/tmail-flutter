import 'dart:isolate';

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
    final emailCacheList = await _emailCacheClient.getListByNestedKey(nestedKey);
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::getAllEmail():: email cache length ${emailCacheList.length} ================');
    for (final emailCache in emailCacheList) {
      log('$runtimeType-in isolate: ${Isolate.current.hashCode}::getAllEmail():ID = ${emailCache.id}, Subject =${emailCache.subject}, Keywords = ${emailCache.keywords}, MailboxIds = ${emailCache.mailboxIds}');
    }
    final emailList = emailCacheList
      .toEmailList()
      .where((email) => _filterEmailByMailbox(email, filterOption, inMailboxId))
      .toList();
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::getAllEmail(): email in mailbox length ${emailList.length} ================');

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
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::_filterEmailByMailbox()::inMailboxId = $inMailboxId | option = $option | email = ${email.id} - ${email.subject} - ${email.keywords} - ${email.mailboxIds}');
    bool isBelongToMailbox = inMailboxId != null
        ? email.belongTo(inMailboxId) && option.filterEmail(email)
        : option.filterEmail(email);
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::_filterEmailByMailbox()::isBelongToMailbox = $isBelongToMailbox');
    return isBelongToMailbox;
  }

  Future<void> update(
    AccountId accountId,
    UserName userName, {
    List<Email>? updated,
    List<Email>? created,
    List<EmailId>? destroyed
  }) async {
    log('$runtimeType-in isolate: ${Isolate.current.hashCode}::update() updated: ${updated?.length} created: ${created?.length} destroyed: ${destroyed?.length}');
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
  }

  Future<void> clean(EmailCleanupRule cleanupRule) async {
      final listEmailCache = await _emailCacheClient.getAll();
      final listEmailIdCacheExpire = listEmailCache
        .where((emailCache) => emailCache.expireTimeCaching(cleanupRule))
        .map((emailCache) => emailCache.id)
        .toList();
      await _emailCacheClient.deleteMultipleItem(listEmailIdCacheExpire);
  }

  Future<void> storeEmail(AccountId accountId, UserName userName, EmailCache emailCache) {
    final keyCache = TupleKey(emailCache.id, accountId.asString, userName.value).encodeKey;
    return _emailCacheClient.insertItem(keyCache, emailCache);
  }

  Future<void> storeMultipleEmails(AccountId accountId, UserName userName, List<EmailCache> emailsCache) async {
    final emailsToCache = Map.fromEntries(emailsCache.map(
      (emailCache) => MapEntry(
        TupleKey(emailCache.id, accountId.asString, userName.value).encodeKey,
        emailCache,
      ),
    ));
    await _emailCacheClient.insertMultipleItem(emailsToCache);
  }

  Future<EmailCache> getStoredEmail(AccountId accountId, UserName userName, EmailId emailId) async {
    final keyCache = TupleKey(emailId.asString, accountId.asString, userName.value).encodeKey;
    final emailCache = await _emailCacheClient.getItem(keyCache);
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
    final emails = await _emailCacheClient.getValuesByListKey(keys);
    return emails;
  }
}