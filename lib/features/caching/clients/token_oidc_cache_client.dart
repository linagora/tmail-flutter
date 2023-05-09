import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/token_oidc_cache.dart';

class TokenOidcCacheClient extends HiveCacheClient<TokenOidcCache> {

  @override
  String get tableName => 'TokenOidcCache';

  @override
  bool get encryption => true;
}