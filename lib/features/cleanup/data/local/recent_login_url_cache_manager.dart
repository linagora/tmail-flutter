
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_login_url_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_url_cleanup_rule.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_url_cache.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/list_recent_login_url_extension.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_url.dart';

class RecentLoginUrlCacheManager extends CacheManagerInteraction {

  final RecentLoginUrlCacheClient _recentLoginUrlCacheClient;

  RecentLoginUrlCacheManager(this._recentLoginUrlCacheClient);

  Future<void> clean(RecentLoginUrlCleanupRule cleanupRule) async {
      final listRecentUrlCache = await _recentLoginUrlCacheClient.getAll();
      listRecentUrlCache.sortByCreationDate();

      if (listRecentUrlCache.length > cleanupRule.storageLimit) {
        final newListKeyRecent = listRecentUrlCache
            .sublist(cleanupRule.storageLimit)
            .map((recent) => recent.url)
            .toList();
        await _recentLoginUrlCacheClient.deleteMultipleItem(newListKeyRecent);
      }
  }

  Future<void> saveLoginUrl(RecentLoginUrlCache recentLoginUrlCache) async {
    final isExist = await _recentLoginUrlCacheClient.isExistItem(
      recentLoginUrlCache.url,
    );

    if (isExist) {
      await _recentLoginUrlCacheClient.updateItem(
        recentLoginUrlCache.url,
        recentLoginUrlCache,
      );
    } else {
      await _recentLoginUrlCacheClient.insertItem(
        recentLoginUrlCache.url,
        recentLoginUrlCache,
      );
    }
  }

  Future<List<RecentLoginUrl>> getAllRecentLoginUrlLatest({
    int? limit,
    String? pattern,
  }) async {
    final listRecentUrlCache = await _recentLoginUrlCacheClient.getAll();
    final listRecentUrl = listRecentUrlCache
        .where((recentCache) => _filterRecentUrlCache(recentCache, pattern))
        .map((recentCache) => recentCache.toRecentLoginUrl())
        .toList();
    listRecentUrl.sortByCreationDate();

    final newLimit = limit ?? 5;

    final newListRecentSUrl = listRecentUrl.length > newLimit
        ? listRecentUrl.sublist(0, newLimit)
        : listRecentUrl;

    return newListRecentSUrl;
  }

  bool _filterRecentUrlCache(
    RecentLoginUrlCache recentLoginUrlCache,
    String? pattern,
  ) {
    if (pattern == null || pattern.trim().isEmpty) {
      return true;
    } else {
      return recentLoginUrlCache.matchUrl(pattern);
    }
  }

  Future<void> clear() => _recentLoginUrlCacheClient.clearAllData();

  @override
  Future<void> migrateHiveToIsolatedHive() async {
    try {
      final legacyMapItems = await _recentLoginUrlCacheClient.getMapItems(
        isolated: false,
      );
      log('$runtimeType::migrateHiveToIsolatedHive(): Length of legacyMapItems: ${legacyMapItems.length}');
      await _recentLoginUrlCacheClient.insertMultipleItem(legacyMapItems);
      log('$runtimeType::migrateHiveToIsolatedHive(): ✅ Migrate Hive box "${_recentLoginUrlCacheClient.tableName}" → IsolatedHive DONE');
    } catch (e) {
      logError('$runtimeType::migrateHiveToIsolatedHive(): ❌ Migrate Hive box "${_recentLoginUrlCacheClient.tableName}" → IsolatedHive FAILED, Error: $e');
    }
  }
}