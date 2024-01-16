
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/sending_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/offline_mode/extensions/list_sending_email_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_email_hive_cache.dart';
import 'package:tmail_ui_user/features/sending_queue/data/exceptions/sending_queue_exceptions.dart';

class SendingEmailCacheManager {

  final SendingEmailHiveCacheClient _hiveCacheClient;

  SendingEmailCacheManager(this._hiveCacheClient);

  Future<SendingEmailHiveCache> storeSendingEmail(
    AccountId accountId,
    UserName userName,
    SendingEmailHiveCache sendingEmailHiveCache
  ) async {
    final keyCache = TupleKey(accountId.asString, userName.value, sendingEmailHiveCache.sendingId).encodeKey;
    await _hiveCacheClient.insertItem(keyCache, sendingEmailHiveCache);
    final newSendingEmailHiveCache = await _hiveCacheClient.getItem(keyCache);
    if (newSendingEmailHiveCache != null) {
      return newSendingEmailHiveCache;
    } else {
      throw NotFoundSendingEmailHiveObject();
    }
  }

  Future<List<SendingEmailHiveCache>> getAllSendingEmailsByAccount(AccountId accountId, UserName userName) async {
     final nestedKey = TupleKey(accountId.asString, userName.value).encodeKey;
     final sendingEmailsCache = await _hiveCacheClient.getListByNestedKey(nestedKey);
     sendingEmailsCache.sortByLatestTime();
     return sendingEmailsCache;
  }

  Future<void> deleteSendingEmail(AccountId accountId, UserName userName, String sendingId) async {
    final keyCache = TupleKey(accountId.asString, userName.value, sendingId).encodeKey;
    await _hiveCacheClient.deleteItem(keyCache);
    final storedSendingEmail = await _hiveCacheClient.getItem(keyCache);
    if (storedSendingEmail != null) {
      throw ExistSendingEmailHiveObject();
    }
  }

  Future<List<SendingEmailHiveCache>> getAllSendingEmails() async {
    final sendingEmailsCache = await _hiveCacheClient.getAll();
    sendingEmailsCache.sortByLatestTime();
    return sendingEmailsCache;
  }

  Future<void> clearAllSendingEmails() => _hiveCacheClient.clearAllData();

  Future<void> clearAllSendingEmailsByAccount(PersonalAccount currentAccount) async {
    final nestedKey = TupleKey(
      currentAccount.accountId!.asString,
      currentAccount.userName!.value
    ).encodeKey;

    await _hiveCacheClient.clearAllDataContainKey(nestedKey);
  }

  Future<SendingEmailHiveCache> updateSendingEmail(
    AccountId accountId,
    UserName userName,
    SendingEmailHiveCache sendingEmailHiveCache
  ) async {
    final keyCache = TupleKey(accountId.asString, userName.value, sendingEmailHiveCache.sendingId).encodeKey;
    await _hiveCacheClient.updateItem(keyCache, sendingEmailHiveCache);
    final newSendingEmailHiveCache = await _hiveCacheClient.getItem(keyCache);
    if (newSendingEmailHiveCache != null) {
      return newSendingEmailHiveCache;
    } else {
      throw NotFoundSendingEmailHiveObject();
    }
  }

  Future<List<SendingEmailHiveCache>> updateMultipleSendingEmail(
    AccountId accountId,
    UserName userName,
    List<SendingEmailHiveCache> listSendingEmailHiveCache
  ) async {
    final mapSendingEmailCache = {
      for (var sendingEmailCache in listSendingEmailHiveCache)
        TupleKey(accountId.asString, userName.value, sendingEmailCache.sendingId).encodeKey: sendingEmailCache
    };
    await _hiveCacheClient.updateMultipleItem(mapSendingEmailCache);
    final newListSendingEmailCache = await _hiveCacheClient.getValuesByListKey(mapSendingEmailCache.keys.toList());
    return newListSendingEmailCache;
  }

  Future<void> deleteMultipleSendingEmail(AccountId accountId, UserName userName, List<String> sendingIds) async {
    final listTupleKey = sendingIds.map((sendingId) => TupleKey(accountId.asString, userName.value, sendingId).encodeKey).toList();
    await _hiveCacheClient.deleteMultipleItem(listTupleKey);
    final newListSendingEmailCache = await _hiveCacheClient.getValuesByListKey(listTupleKey);
    if (newListSendingEmailCache.isNotEmpty) {
      throw ExistSendingEmailHiveObject();
    }
  }

  Future<SendingEmailHiveCache> getStoredSendingEmail(AccountId accountId, UserName userName, String sendingId) async {
    final keyCache = TupleKey(accountId.asString, userName.value, sendingId).encodeKey;
    final storedSendingEmail = await _hiveCacheClient.getItem(keyCache);
    if (storedSendingEmail != null) {
      return storedSendingEmail;
    } else {
      throw NotFoundSendingEmailHiveObject();
    }
  }

  Future<void> closeSendingEmailHiveCacheBox() => _hiveCacheClient.closeBox();
}