
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/file_utils.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/detailed_email_hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/detailed_email_extension.dart';
import 'package:tmail_ui_user/features/email/domain/model/detailed_email.dart';
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

  Future<void> storeOpenedEmail(
    AccountId accountId,
    UserName userName,
    DetailedEmail detailedEmail
  ) async {
    final listDetailedEmails = await getAllDetailedEmails(accountId, userName);

    final checkDuplicateDetailedEmail = await _handleDuplicateOpenedEmail(accountId, detailedEmail);

    if (checkDuplicateDetailedEmail) {
      return Future.value();
    }

    if (listDetailedEmails.length >= CachingConstants.maxNumberOpenedEmailsForOffline) {
      final latestEmail = listDetailedEmails.last;
      log('DetailedEmailCacheManager::handleStoreDetailedEmail():latestEmail: $latestEmail');
      await removeDetailedEmail(accountId, userName, latestEmail.emailId);
    }
    await insertDetailedEmail(accountId, userName, detailedEmail.toHiveCache());
  }

  Future<bool> _handleDuplicateOpenedEmail(AccountId accountId, DetailedEmail detailedEmail) async {
    final emailContentPath = await _getEmailContentPath(detailedEmail);
    final detailedEmailCacheExists = await _getDetailedEmailCache(accountId);

    if (emailContentPath != null && detailedEmailCacheExists) {
      return true;
    } else {
      return false;
    }
  }

  Future<String?> _getEmailContentPath(DetailedEmail detailedEmail) async {
    final fileSaved = await _fileUtils.getFromFile(
      nameFile: detailedEmail.emailId.asString,
      folderPath: detailedEmail.folderPath,
      extensionFile: ExtensionType.text.value
    );
    log('DetailedEmailCacheManager::_getDetailedEmailCache():_getEmailContentPath: $fileSaved');
    return fileSaved;
  }

  Future<bool> _getDetailedEmailCache(AccountId accountId) async {
    final detailedEmailCache = await _cacheClient.getItem(accountId.asString);
    log('DetailedEmailCacheManager::_getDetailedEmailCache():_getDetailedEmailCache: $detailedEmailCache');
    if (detailedEmailCache != null) {
      return true;
    } else {
      return false;
    }
  }
}