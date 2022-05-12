import 'package:tmail_ui_user/features/thread/data/datasource/recent_search_datasource.dart';
import 'package:tmail_ui_user/features/thread/data/model/recent_search_hive_cache.dart';
import 'package:tmail_ui_user/features/thread/domain/repository/recent_search_repository.dart';

class RecentSearchRepositoryImpl extends RecentSearchRepository {
  final RecentSearchDataSource recentSearchDataSource;

  RecentSearchRepositoryImpl(this.recentSearchDataSource);

  @override
  Future<List<RecentSearchHiveCache>> getAll() async {
    return recentSearchDataSource.getAll();
  }

  @override
  Future<List<RecentSearchHiveCache>> storeKeyword(String keyword) async {
     return recentSearchDataSource.storeKeyword(keyword);
  }
}
