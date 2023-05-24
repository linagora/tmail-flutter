
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/caching/clients/detailed_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/offline_mode/extensions/list_detailed_email_hive_cache_extension.dart';
import 'package:tmail_ui_user/features/offline_mode/model/detailed_email_hive_cache.dart';

class DetailedEmailCacheManager {

  final DetailedEmailHiveCacheClient _cacheClient;
  final FileUtils _fileUtils;

  DetailedEmailCacheManager(this._cacheClient, this._fileUtils);

  Future<DetailedEmailHiveCache> handleStoreDetailedEmail(
    AccountId accountId,
    UserName userName,
    DetailedEmailHiveCache detailedEmailCache
  ) async {
    final listDetailedEmails = await getAllDetailedEmails(accountId, userName);

    if (listDetailedEmails.length >= CachingConstants.maxNumberNewEmailsForOffline) {
      final lastElementsListEmail = listDetailedEmails.sublist(CachingConstants.maxNumberNewEmailsForOffline, listDetailedEmails.length);
      for (var email in lastElementsListEmail) {
        log('DetailedEmailCacheManager::handleStoreDetailedEmail():latestEmail: $email');
        if (email.emailContentPath != null) {
          await _deleteFileExisted(email.emailContentPath!);
        }
        await removeDetailedEmail(accountId, userName, email.emailId);
      }
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

  Future<void> _deleteFileExisted(String pathFile) async {
    await _fileUtils.deleteFile(pathFile);
  }

  Future<DetailedEmailHiveCache?> getDetailEmailExistedInCache(
    AccountId accountId,
    UserName userName,
    EmailId emailId
  ) async {
    final keyCache = TupleKey(emailId.asString, accountId.asString, userName.value).encodeKey;
    final detailedEmailCache = await _cacheClient.getItem(keyCache, needToReopen: true);
    log('DetailedEmailCacheManager::getDetailEmailExistedInCache():Email: $detailedEmailCache');
    return detailedEmailCache;
  }
}