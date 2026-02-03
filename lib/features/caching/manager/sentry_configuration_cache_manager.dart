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
    final sentryConfigCache =
        await _configurationCacheClient.getItem(_configurationCacheKey);
    if (sentryConfigCache == null) {
      throw NotFoundSentryConfigurationException();
    } else {
      return sentryConfigCache;
    }
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
    final sentryUserCache = await _userCacheClient.getItem(_userCacheKey);
    if (sentryUserCache == null) {
      throw NotFoundSentryUserException();
    } else {
      return sentryUserCache;
    }
  }

  Future<void> saveSentryUser(
    SentryUserCache sentryUserCache,
  ) async {
    await _userCacheClient.insertItem(_userCacheKey, sentryUserCache);
  }
}
