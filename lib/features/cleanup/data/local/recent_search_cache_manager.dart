
import 'package:tmail_ui_user/features/caching/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/cleanup/domain/model/recent_search_cleanup_rule.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/recent_search_cache.dart';

class RecentSearchCacheManager {

  final RecentSearchCacheClient _recentSearchCacheClient;

  RecentSearchCacheManager(this._recentSearchCacheClient);

  Future<void> clean(RecentSearchCleanupRule cleanupRule) async {
    final recentSearchCacheExist = await _recentSearchCacheClient.isExistTable();
    if (recentSearchCacheExist) {
      final listRecentSearchCache = await _recentSearchCacheClient.getAll();
      listRecentSearchCache.sortByCreationDate();

      if (listRecentSearchCache.length > cleanupRule.storageLimit) {
        final newListKeyRecent = listRecentSearchCache
            .sublist(cleanupRule.storageLimit)
            .map((recent) => recent.value)
            .toList();
        await _recentSearchCacheClient.deleteMultipleItem(newListKeyRecent);
      }
    }
  }
}