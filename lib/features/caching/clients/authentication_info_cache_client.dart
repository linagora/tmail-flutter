import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';

class AuthenticationInfoCacheClient extends HiveCacheClient<AuthenticationInfoCache> {

  @override
  String get tableName => 'AuthenticationInfoCache';

  @override
  bool get encryption => true;
}