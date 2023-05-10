
import 'package:tmail_ui_user/features/caching/clients/recent_search_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/datasource/search_datasource.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/recent_search_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/extensions/list_recent_search_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/recent_search.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class SearchDataSourceImpl extends SearchDataSource {

  final RecentSearchCacheClient _recentSearchCacheClient;
  final ExceptionThrower _exceptionThrower;

  SearchDataSourceImpl(this._recentSearchCacheClient, this._exceptionThrower);

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
    }).catchError(_exceptionThrower.throwException);
  }

  @override
  Future<List<RecentSearch>> getAllRecentSearchLatest({int? limit, String? pattern}) {
    return Future.sync(() async {
      final listRecentSearchCache = await _recentSearchCacheClient.getAll();
      final listRecentSearch = listRecentSearchCache
          .where((recentCache) => _filterRecentSearchCache(recentCache, pattern))
          .map((recentCache) => recentCache.toRecentSearch())
          .toList();
      listRecentSearch.sortByCreationDate();

      final newLimit = limit ?? 10;

      final newListRecentSearch = listRecentSearch.length > newLimit
        ? listRecentSearch.sublist(0, newLimit)
        : listRecentSearch;

      return newListRecentSearch;
    }).catchError(_exceptionThrower.throwException);
  }

  bool _filterRecentSearchCache(RecentSearchCache recentSearchCache, String? pattern) {
    if (pattern == null || pattern.trim().isEmpty) {
      return true;
    } else {
      return recentSearchCache.match(pattern);
    }
  }
}