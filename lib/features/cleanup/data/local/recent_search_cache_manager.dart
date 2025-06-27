
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_search_cleanup_rule.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/recent_search_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/extensions/list_recent_search_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';

class RecentSearchCacheManager extends CacheManagerInteraction {

  static const int _defaultRecentSearchLimit = 10;

  final RecentSearchCacheClient _recentSearchCacheClient;

  RecentSearchCacheManager(this._recentSearchCacheClient);

  Future<void> clean(RecentSearchCleanupRule cleanupRule) async {
    final nestedKey = TupleKey(
      cleanupRule.accountId.asString,
      cleanupRule.userName.value,
    ).encodeKey;

    final listRecentSearchCache = await _recentSearchCacheClient
        .getListByNestedKey(nestedKey);

    listRecentSearchCache.sortByCreationDate();

    if (listRecentSearchCache.length > cleanupRule.storageLimit) {
      final newListKeyRecent = listRecentSearchCache
          .sublist(cleanupRule.storageLimit)
          .map((recent) => recent.toRecentSearch().generateTupleKey(
            cleanupRule.accountId,
            cleanupRule.userName,
          ))
          .toList();
      log('RecentSearchCacheManager::clean: list recent to delete $newListKeyRecent');
      await _recentSearchCacheClient.deleteMultipleItem(newListKeyRecent);
    }
  }

  Future<void> saveRecentSearch(
    AccountId accountId,
    UserName userName,
    RecentSearch recentSearch,
  ) async {
    final keyCache = recentSearch.generateTupleKey(accountId, userName);
    final exist = await _recentSearchCacheClient.isExistItem(keyCache);

    if (exist) {
      await _recentSearchCacheClient.updateItem(
        keyCache,
        recentSearch.toRecentSearchCache(),
      );
    } else {
      await _recentSearchCacheClient.insertItem(
        keyCache,
        recentSearch.toRecentSearchCache(),
      );
    }
  }

  Future<List<RecentSearch>> getAllLatest(
    AccountId accountId,
    UserName userName,
    {
      int? limit,
      String? pattern,
    }
  ) async {
    final nestedKey = TupleKey(accountId.asString, userName.value).encodeKey;
    final listRecentSearchCache = await _recentSearchCacheClient
        .getListByNestedKey(nestedKey);

    final listRecentSearch = listRecentSearchCache
        .where((recentCache) => _filterRecentSearchCache(recentCache, pattern))
        .map((recentCache) => recentCache.toRecentSearch())
        .toList();

    listRecentSearch.sortByCreationDate();

    final newLimit = limit ?? _defaultRecentSearchLimit;

    final newListRecentSearch = listRecentSearch.length > newLimit
        ? listRecentSearch.sublist(0, newLimit)
        : listRecentSearch;

    return newListRecentSearch;
  }

  bool _filterRecentSearchCache(RecentSearchCache recentSearchCache, String? pattern) {
    if (pattern == null || pattern.trim().isNotEmpty) {
      return true;
    } else {
      return recentSearchCache.match(pattern);
    }
  }

  Future<void> clear() => _recentSearchCacheClient.clearAllData();

  @override
  Future<void> migrateHiveToIsolatedHive() async {
    try {
      final legacyMapItems = await _recentSearchCacheClient.getMapItems(
        isolated: false,
      );
      log('$runtimeType::migrateHiveToIsolatedHive(): Length of legacyMapItems: ${legacyMapItems.length}');
      await _recentSearchCacheClient.insertMultipleItem(legacyMapItems);
      log('$runtimeType::migrateHiveToIsolatedHive(): ✅ Migrate Hive box "${_recentSearchCacheClient.tableName}" → IsolatedHive DONE');
    } catch (e) {
      logError('$runtimeType::migrateHiveToIsolatedHive(): ❌ Migrate Hive box "${_recentSearchCacheClient.tableName}" → IsolatedHive FAILED, Error: $e');
    }
  }
}