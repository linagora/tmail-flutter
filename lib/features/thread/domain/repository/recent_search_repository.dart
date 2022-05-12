
import 'package:tmail_ui_user/features/thread/data/model/recent_search_hive_cache.dart';

abstract class RecentSearchRepository {

  Future<List<RecentSearchHiveCache>> getAll();

  Future<List<RecentSearchHiveCache>> storeKeyword(String keyword);
  
}