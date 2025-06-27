
import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/caching/clients/recent_login_username_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_username_cleanup_rule.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_username_cache.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/list_recent_login_username_extension.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';

class RecentLoginUsernameCacheManager extends CacheManagerInteraction {

  final RecentLoginUsernameCacheClient _recentLoginUsernameCacheClient;

  RecentLoginUsernameCacheManager(this._recentLoginUsernameCacheClient);

  Future<void> clean(RecentLoginUsernameCleanupRule cleanupRule) async {
      final listRecentUsernameCache = await _recentLoginUsernameCacheClient.getAll();
      listRecentUsernameCache.sortByCreationDate();

      if (listRecentUsernameCache.length > cleanupRule.storageLimit) {
        final newListKeyRecent = listRecentUsernameCache
            .sublist(cleanupRule.storageLimit)
            .map((recent) => recent.username)
            .toList();
        await _recentLoginUsernameCacheClient.deleteMultipleItem(newListKeyRecent);
      }
  }

  Future<List<RecentLoginUsername>> getAllRecentLoginUsernamesLatest({
    int? limit,
    String? pattern,
  }) async {
    final listRecentUsernameCache =
        await _recentLoginUsernameCacheClient.getAll();
    final listValidRecentUsername = listRecentUsernameCache
        .where((recentCache) =>
            _filterRecentLoginUsernameCache(recentCache, pattern))
        .map((recentCache) => recentCache.toRecentLoginUsername())
        .toList();

    listValidRecentUsername.sortByCreationDate();

    final newLimit = limit ?? 5;

    return listValidRecentUsername.length > newLimit
        ? listValidRecentUsername.sublist(0, newLimit)
        : listValidRecentUsername;
  }

  Future<void> saveLoginUsername(
    RecentLoginUsername recentLoginUsername,
  ) async {
    final isExist = await _recentLoginUsernameCacheClient.isExistItem(
      recentLoginUsername.username,
    );
    if (isExist) {
      await _recentLoginUsernameCacheClient.updateItem(
        recentLoginUsername.username,
        recentLoginUsername.toRecentLoginUsernameCache(),
      );
    } else {
      await _recentLoginUsernameCacheClient.insertItem(
        recentLoginUsername.username,
        recentLoginUsername.toRecentLoginUsernameCache(),
      );
    }
  }

  bool _filterRecentLoginUsernameCache(
    RecentLoginUsernameCache recentLoginUsernameCache,
    String? pattern,
  ) {
    if (pattern == null || pattern.trim().isEmpty) {
      return true;
    } else {
      return recentLoginUsernameCache.matchUsername(pattern);
    }
  }

  Future<void> clear() => _recentLoginUsernameCacheClient.clearAllData();

  @override
  Future<void> migrateHiveToIsolatedHive() async {
    try {
      final legacyMapItems = await _recentLoginUsernameCacheClient.getMapItems(
        isolated: false,
      );
      log('$runtimeType::migrateHiveToIsolatedHive(): Length of legacyMapItems: ${legacyMapItems.length}');
      await _recentLoginUsernameCacheClient.insertMultipleItem(legacyMapItems);
      log('$runtimeType::migrateHiveToIsolatedHive(): ✅ Migrate Hive box "${_recentLoginUsernameCacheClient.tableName}" → IsolatedHive DONE');
    } catch (e) {
      logError('$runtimeType::migrateHiveToIsolatedHive(): ❌ Migrate Hive box "${_recentLoginUsernameCacheClient.tableName}" → IsolatedHive FAILED, Error: $e');
    }
  }
}