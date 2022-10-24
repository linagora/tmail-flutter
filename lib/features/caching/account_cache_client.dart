import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';

class AccountCacheClient extends HiveCacheClient<AccountCache> {

  @override
  String get tableName => 'AccountCache';
}