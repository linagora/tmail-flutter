import 'package:tmail_ui_user/features/caching/clients/sentry_configuration_cache_client.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_configuration_cache.dart';
import 'package:tmail_ui_user/features/caching/exceptions/local_storage_exception.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

class SentryConfigurationCacheManager {
  final SentryConfigurationCacheClient _cacheClient;
  final String _cacheKey = CachingConstants.sentryConfigurationCacheKeyName;

  SentryConfigurationCacheManager(this._cacheClient);

  Future<SentryConfigurationCache> getSentryConfiguration() async {
    final sentryConfigCache = await _cacheClient.getItem(_cacheKey);
    if (sentryConfigCache == null) {
      throw NotFoundSentryConfigurationException();
    } else {
      return sentryConfigCache;
    }
  }

  Future<void> saveSentryConfiguration(
    SentryConfigurationCache sentryConfigurationCache,
  ) async {
    await _cacheClient.insertItem(_cacheKey, sentryConfigurationCache);
  }
}
