import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_configuration_cache.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

class SentryConfigurationCacheClient
    extends HiveCacheClient<SentryConfigurationCache> {
  @override
  String get tableName => CachingConstants.sentryConfigurationCacheBoxName;

  @override
  bool get encryption => true;
}
