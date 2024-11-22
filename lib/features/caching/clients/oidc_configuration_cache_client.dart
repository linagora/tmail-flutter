import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/login/data/model/oidc_configuration_cache.dart';

class OidcConfigurationCacheClient extends HiveCacheClient<OidcConfigurationCache> {

  @override
  String get tableName => CachingConstants.oidcConfigurationCacheBoxName;

  @override
  bool get encryption => true;
}