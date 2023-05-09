import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_username_cache.dart';

class RecentLoginUsernameCacheClient extends HiveCacheClient<RecentLoginUsernameCache> {
    
  @override
  String get tableName => 'RecentLoginUsernameCache';
}