
import 'package:tmail_ui_user/features/caching/clients/recent_login_url_cache_client.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_login_url_cleanup_rule.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_url_cache.dart';

class RecentLoginUrlCacheManager {

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
}