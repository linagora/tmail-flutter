
import 'package:tmail_ui_user/features/caching/recent_login_username_cache_client.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_username_cleanup_rule.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_username_cache.dart';

class RecentLoginUsernameCacheManager {

  final RecentLoginUsernameCacheClient _recentLoginUsernameCacheClient;

  RecentLoginUsernameCacheManager(this._recentLoginUsernameCacheClient);

  Future<void> clean(RecentLoginUsernameCleanupRule cleanupRule) async {
    final recentCacheExist = await _recentLoginUsernameCacheClient.isExistTable();
    if (recentCacheExist) {
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
  }
}