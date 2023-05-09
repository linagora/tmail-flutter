import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_url_cache.dart';

class RecentLoginUrlCacheClient extends HiveCacheClient<RecentLoginUrlCache> {
  
  @override
  String get tableName => 'RecentLoginUrlCache';
}