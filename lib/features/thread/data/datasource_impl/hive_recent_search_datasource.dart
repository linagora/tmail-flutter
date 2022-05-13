import 'package:tmail_ui_user/features/caching/recent_search_client.dart';
import 'package:tmail_ui_user/features/thread/data/datasource/recent_search_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/model/recent_search_hive_cache.dart';

class HiveRecentSearchDataSource implements RecentSearchDataSource {
  final RecentSearchClient _recentSearchClient;

  HiveRecentSearchDataSource(this._recentSearchClient);

  @override
  Future<List<RecentSearchHiveCache>> getAll() async {
    return await _recentSearchClient.getAll();
  }

  @override
  Future<List<RecentSearchHiveCache>> storeKeyword(String keyword) async {
      return _recentSearchClient.storeRecentSeachToHive(keyword);
  }
}
