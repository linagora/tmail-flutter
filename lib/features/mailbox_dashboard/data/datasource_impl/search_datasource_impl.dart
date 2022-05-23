
import 'package:tmail_ui_user/features/caching/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/search_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/recent_search_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';

class SearchDataSourceImpl extends SearchDataSource {

  final RecentSearchCacheClient _recentSearchCacheClient;

  SearchDataSourceImpl(this._recentSearchCacheClient);

  @override
  Future<void> saveRecentSearch(RecentSearch recentSearch) {
    return Future.sync(() async {
      if (await _recentSearchCacheClient.isExistItem(recentSearch.value)) {
        await _recentSearchCacheClient.updateItem(
            recentSearch.value,
            recentSearch.toRecentSearchCache());
      } else {
        await _recentSearchCacheClient.insertItem(
            recentSearch.value,
            recentSearch.toRecentSearchCache());
      }
    }).catchError((error) {
      throw error;
    });
  }
}