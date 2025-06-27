
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/sending_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/offline_mode/extensions/list_sending_email_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_email_hive_cache.dart';
import 'package:tmail_ui_user/features/sending_queue/data/exceptions/sending_queue_exceptions.dart';

class SendingEmailCacheManager extends CacheManagerInteraction {

  final SendingEmailHiveCacheClient _hiveCacheClient;

  SendingEmailCacheManager(this._hiveCacheClient);

  Future<SendingEmailHiveCache> storeSendingEmail(
    AccountId accountId,
    UserName userName,
    SendingEmailHiveCache sendingEmailHiveCache
  ) async {
    final keyCache = TupleKey(sendingEmailHiveCache.sendingId, accountId.asString, userName.value).encodeKey;
    await _hiveCacheClient.insertItem(keyCache, sendingEmailHiveCache);
    final newSendingEmailHiveCache = await _hiveCacheClient.getItem(keyCache);
    if (newSendingEmailHiveCache != null) {
      return newSendingEmailHiveCache;
    } else {
      throw NotFoundSendingEmailHiveObject();
    }
  }

  Future<List<SendingEmailHiveCache>> getAllSendingEmailsByTupleKey(AccountId accountId, UserName userName) async {
    final nestedKey = TupleKey(accountId.asString, userName.value).encodeKey;
    final sendingEmailsCache = await _hiveCacheClient.getListByNestedKey(nestedKey);
     sendingEmailsCache.sortByLatestTime();
     return sendingEmailsCache;
  }

  Future<void> deleteSendingEmail(AccountId accountId, UserName userName, String sendingId) async {
    final keyCache = TupleKey(sendingId, accountId.asString, userName.value).encodeKey;
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

  Future<SendingEmailHiveCache> updateSendingEmail(
    AccountId accountId,
    UserName userName,
    SendingEmailHiveCache sendingEmailHiveCache
  ) async {
    final keyCache = TupleKey(sendingEmailHiveCache.sendingId, accountId.asString, userName.value).encodeKey;
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
        TupleKey(sendingEmailCache.sendingId, accountId.asString, userName.value).encodeKey: sendingEmailCache
    };
    await _hiveCacheClient.updateMultipleItem(mapSendingEmailCache);
    final newListSendingEmailCache = await _hiveCacheClient.getValuesByListKey(mapSendingEmailCache.keys.toList());
    return newListSendingEmailCache;
  }

  Future<void> deleteMultipleSendingEmail(AccountId accountId, UserName userName, List<String> sendingIds) async {
    final listTupleKey = sendingIds.map((sendingId) => TupleKey(sendingId, accountId.asString, userName.value).encodeKey).toList();
    await _hiveCacheClient.deleteMultipleItem(listTupleKey);
    final newListSendingEmailCache = await _hiveCacheClient.getValuesByListKey(listTupleKey);
    if (newListSendingEmailCache.isNotEmpty) {
      throw ExistSendingEmailHiveObject();
    }
  }

  Future<SendingEmailHiveCache> getStoredSendingEmail(AccountId accountId, UserName userName, String sendingId) async {
    final keyCache = TupleKey(sendingId, accountId.asString, userName.value).encodeKey;
    final storedSendingEmail = await _hiveCacheClient.getItem(keyCache);
    if (storedSendingEmail != null) {
      return storedSendingEmail;
    } else {
      throw NotFoundSendingEmailHiveObject();
    }
  }

  Future<void> closeSendingEmailHiveCacheBox() => _hiveCacheClient.closeBox();

  @override
  Future<void> migrateHiveToIsolatedHive() async {
    try {
      final legacyMapItems = await _hiveCacheClient.getMapItems(
        isolated: false,
      );
      log('$runtimeType::migrateHiveToIsolatedHive(): Length of legacyMapItems: ${legacyMapItems.length}');
      await _hiveCacheClient.insertMultipleItem(legacyMapItems);
      log('$runtimeType::migrateHiveToIsolatedHive(): ✅ Migrate Hive box "${_hiveCacheClient.tableName}" → IsolatedHive DONE');
    } catch (e) {
      logError('$runtimeType::migrateHiveToIsolatedHive(): ❌ Migrate Hive box "${_hiveCacheClient.tableName}" → IsolatedHive FAILED, Error: $e');
    }
  }
}