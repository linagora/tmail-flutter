import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/opened_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_cache_exceptions.dart';
import 'package:tmail_ui_user/features/offline_mode/extensions/list_detailed_email_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/model/detailed_email_hive_cache.dart';

class OpenedEmailCacheManager extends CacheManagerInteraction {

  final OpenedEmailHiveCacheClient _cacheClient;
  final FileUtils _fileUtils;

  OpenedEmailCacheManager(this._cacheClient, this._fileUtils);

  Future<void> insertDetailedEmail(
    AccountId accountId,
    UserName userName,
    DetailedEmailHiveCache detailedEmailCache
  ) {
    final keyCache = TupleKey(detailedEmailCache.emailId, accountId.asString, userName.value).encodeKey;
    log('OpenedEmailCacheManager::insertDetailedEmail(): $keyCache');
    return _cacheClient.insertItem(keyCache, detailedEmailCache);
  }

  Future<void> removeDetailedEmail(
    AccountId accountId,
    UserName userName,
    String emailId
  ) {
    final keyCache = TupleKey(emailId, accountId.asString, userName.value).encodeKey;
    log('OpenedEmailCacheManager::removeDetailedEmail(): $keyCache');
    return _cacheClient.deleteItem(keyCache);
  }

  Future<List<DetailedEmailHiveCache>> getAllDetailedEmails(AccountId accountId, UserName userName) async {
    final nestedKey = TupleKey(accountId.asString, userName.value).encodeKey;
    final detailedEmailCacheList = await _cacheClient.getListByNestedKey(nestedKey);
    detailedEmailCacheList.sortByLatestTime();
    log('OpenedEmailCacheManager::getAllDetailedEmails():SIZE: ${detailedEmailCacheList.length}');
    return detailedEmailCacheList;
  }

  Future<DetailedEmailHiveCache> storeOpenedEmail(
    AccountId accountId,
    UserName userName,
    DetailedEmailHiveCache detailedEmailCache
  ) async {
    final listDetailedEmails = await getAllDetailedEmails(accountId, userName);

    if (listDetailedEmails.length >= CachingConstants.maxNumberOpenedEmailsForOffline) {
      final lastElementsListEmail = listDetailedEmails.sublist(CachingConstants.maxNumberOpenedEmailsForOffline - 1);
      for (var email in lastElementsListEmail) {
        if (email.emailContentPath != null) {
          await _deleteFileExisted(email.emailContentPath!);
        }
        await removeDetailedEmail(accountId, userName, email.emailId);
      }
    }
    await insertDetailedEmail(accountId, userName, detailedEmailCache);

    return detailedEmailCache;
  }

  Future<DetailedEmailHiveCache> getStoredOpenedEmail(
    AccountId accountId,
    UserName userName,
    EmailId emailId
  ) async {
    final keyCache = TupleKey(emailId.asString, accountId.asString, userName.value).encodeKey;
    final detailedEmailCache = await _cacheClient.getItem(keyCache);
    if (detailedEmailCache != null) {
      return detailedEmailCache;
    } else {
      throw NotFoundStoredOpenedEmailException();
    }
  }

  Future<void> _deleteFileExisted(String pathFile) async {
    await _fileUtils.deleteFile(pathFile);
  }

  Future<void> clear() => _cacheClient.clearAllData();

  Future<void> deleteByKey(String key) =>
      _cacheClient.clearAllDataContainKey(key);

  @override
  Future<void> migrateHiveToIsolatedHive() async {
    try {
      final legacyMapItems = await _cacheClient.getMapItems(
        isolated: false,
      );
      log('$runtimeType::migrateHiveToIsolatedHive(): Length of legacyMapItems: ${legacyMapItems.length}');
      await _cacheClient.insertMultipleItem(legacyMapItems);
      log('$runtimeType::migrateHiveToIsolatedHive(): ✅ Migrate Hive box "${_cacheClient.tableName}" → IsolatedHive DONE');
    } catch (e) {
      logError('$runtimeType::migrateHiveToIsolatedHive(): ❌ Migrate Hive box "${_cacheClient.tableName}" → IsolatedHive FAILED, Error: $e');
    }
  }
}