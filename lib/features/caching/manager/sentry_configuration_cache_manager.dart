import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/caching/clients/sentry_configuration_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/sentry_user_cache_client.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_configuration_cache.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_user_cache.dart';
import 'package:tmail_ui_user/features/caching/exceptions/local_storage_exception.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

class SentryConfigurationCacheManager {
  final SentryConfigurationCacheClient _configurationCacheClient;
  final SentryUserCacheClient _userCacheClient;
  final String _configurationCacheKey =
      CachingConstants.sentryConfigurationCacheKeyName;
  final String _userCacheKey = CachingConstants.sentryUserCacheKeyName;

  SentryConfigurationCacheManager(
    this._configurationCacheClient,
    this._userCacheClient,
  );

  Future<SentryConfigurationCache> getSentryConfiguration() async {
    final cache = await _configurationCacheClient.getItem(_configurationCacheKey);
    if (cache == null) throw const NotFoundSentryConfigurationException();
    return cache;
  }

  Future<void> saveSentryConfiguration(
    SentryConfigurationCache sentryConfigurationCache,
  ) async {
    await _configurationCacheClient.insertItem(
      _configurationCacheKey,
      sentryConfigurationCache,
    );
  }

  Future<SentryUserCache> getSentryUser() async {
    final cache = await _userCacheClient.getItem(_userCacheKey);
    if (cache == null) throw const NotFoundSentryUserException();
    return cache;
  }

  Future<void> saveSentryUser(
    SentryUserCache sentryUserCache,
  ) async {
    await _userCacheClient.insertItem(_userCacheKey, sentryUserCache);
  }

  Future<void> clearSentryConfiguration() async {
    try {
      await _configurationCacheClient.clearAllData();
    } catch (e, st) {
      logError(
        'SentryConfigurationCacheManager::clearSentryConfiguration: Failed to clear config cache',
        exception: e,
        stackTrace: st,
      );
    }
    try {
      await _userCacheClient.clearAllData();
    } catch (e, st) {
      logError(
        'SentryConfigurationCacheManager::clearSentryConfiguration: Failed to clear user cache',
        exception: e,
        stackTrace: st,
      );
    }
  }
}
