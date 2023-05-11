
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/detailed_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/offline_mode/extensions/list_detailed_email_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/model/detailed_email_hive_cache.dart';

class DetailedEmailCacheManager {

  final DetailedEmailHiveCacheClient _cacheClient;

  DetailedEmailCacheManager(this._cacheClient);

  Future<DetailedEmailHiveCache> handleStoreDetailedEmail(
    AccountId accountId,
    UserName userName,
    DetailedEmailHiveCache detailedEmailCache
  ) async {
    final listDetailedEmails = await getAllDetailedEmails(accountId, userName);

    if (listDetailedEmails.length >= CachingConstants.maxNumberNewEmailsForOffline) {
      final latestEmail = listDetailedEmails.last;
      log('DetailedEmailCacheManager::handleStoreDetailedEmail():latestEmail: $latestEmail');
      await removeDetailedEmail(accountId, userName, latestEmail.emailId);
    }
    await insertDetailedEmail(accountId, userName, detailedEmailCache);

    return detailedEmailCache;
  }

  Future<void> insertDetailedEmail(
    AccountId accountId,
    UserName userName,
    DetailedEmailHiveCache detailedEmailCache
  ) {
    final keyCache = TupleKey(detailedEmailCache.emailId, accountId.asString, userName.value).encodeKey;
    log('DetailedEmailCacheManager::insertDetailedEmail(): $keyCache');
    return _cacheClient.insertItem(keyCache, detailedEmailCache);
  }

  Future<void> removeDetailedEmail(
    AccountId accountId,
    UserName userName,
    String emailId
  ) {
    final keyCache = TupleKey(emailId, accountId.asString, userName.value).encodeKey;
    log('DetailedEmailCacheManager::removeDetailedEmail(): $keyCache');
    return _cacheClient.deleteItem(keyCache);
  }

  Future<List<DetailedEmailHiveCache>> getAllDetailedEmails(AccountId accountId, UserName userName) async {
    final detailedEmailCacheList = await _cacheClient.getListByTupleKey(accountId.asString, userName.value);
    detailedEmailCacheList.sortByLatestTime();
    log('DetailedEmailCacheManager::getAllDetailedEmails():SIZE: ${detailedEmailCacheList.length}');
    return detailedEmailCacheList;
  }
}