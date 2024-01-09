
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/recent_search_cache.dart';

class RecentSearchCacheClient extends HiveCacheClient<RecentSearchCache> {

  @override
  String get tableName => CachingConstants.recentSearchCacheBoxName;
}