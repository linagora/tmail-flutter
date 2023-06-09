
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
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
    final keyCache = TupleKey(sendingEmailHiveCache.sendingId, accountId.asString, userName.value).encodeKey;
    log('SendingEmailCacheManager::storeSendingEmail():keyCache: $keyCache | sendingEmailHiveCache: $sendingEmailHiveCache');
    await _hiveCacheClient.insertItem(keyCache, sendingEmailHiveCache);
    final newSendingEmailHiveCache = await _hiveCacheClient.getItem(keyCache);
    if (newSendingEmailHiveCache != null) {
      log('SendingEmailCacheManager::storeSendingEmail():sendingId: ${newSendingEmailHiveCache.sendingId} | sendingState: ${newSendingEmailHiveCache.sendingState}');
      return newSendingEmailHiveCache;
    } else {
      throw NotFoundSendingEmailHiveObject();
    }
  }

  Future<List<SendingEmailHiveCache>> getAllSendingEmailsByTupleKey(
    AccountId accountId,
    UserName userName,
    {bool needToReopen = false}
  ) async {
     final sendingEmailsCache = await _hiveCacheClient.getListByTupleKey(
       accountId.asString,
       userName.value,
       needToReopen: needToReopen);
     log('SendingEmailCacheManager::getAllSendingEmailsByTupleKey():COUNT: ${sendingEmailsCache.length}');
     sendingEmailsCache.sortByLatestTime();
     return sendingEmailsCache;
  }

  Future<void> deleteSendingEmail(
    AccountId accountId,
    UserName userName,
    String sendingId,
    {bool needToReopen = false}
  ) async {
    final keyCache = TupleKey(sendingId, accountId.asString, userName.value).encodeKey;
    log('SendingEmailCacheManager::deleteSendingEmail():keyCache: $keyCache');
    await _hiveCacheClient.deleteItem(keyCache, needToReopen: needToReopen);
    final storedSendingEmail = await _hiveCacheClient.getItem(keyCache);
    if (storedSendingEmail != null) {
      log('SendingEmailCacheManager::deleteSendingEmail():sendingId: ${storedSendingEmail.sendingId}');
      throw ExistSendingEmailHiveObject();
    }
  }

  Future<List<SendingEmailHiveCache>> getAllSendingEmails({bool needToReopen = false}) async {
    final sendingEmailsCache = await _hiveCacheClient.getAll(needToReopen: needToReopen);
    log('SendingEmailCacheManager::getAllSendingEmails():COUNT: ${sendingEmailsCache.length}');
    sendingEmailsCache.sortByLatestTime();
    return sendingEmailsCache;
  }

  Future<void> clearAllSendingEmails() => _hiveCacheClient.clearAllData();

  Future<SendingEmailHiveCache> updateSendingEmail(
    AccountId accountId,
    UserName userName,
    SendingEmailHiveCache sendingEmailHiveCache,
    {bool needToReopen = false}
  ) async {
    final keyCache = TupleKey(sendingEmailHiveCache.sendingId, accountId.asString, userName.value).encodeKey;
    log('SendingEmailCacheManager::updateSendingEmail():keyCache: $keyCache | sendingEmailHiveCache: $sendingEmailHiveCache');
    await _hiveCacheClient.updateItem(keyCache, sendingEmailHiveCache, needToReopen: needToReopen);
    final newSendingEmailHiveCache = await _hiveCacheClient.getItem(keyCache);
    if (newSendingEmailHiveCache != null) {
      log('SendingEmailCacheManager::updateSendingEmail():sendingId: ${newSendingEmailHiveCache.sendingId} | sendingState: ${newSendingEmailHiveCache.sendingState}');
      return newSendingEmailHiveCache;
    } else {
      throw NotFoundSendingEmailHiveObject();
    }
  }
}