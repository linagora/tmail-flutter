import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/caching/clients/sentry_configuration_cache_client.dart';
import 'package:tmail_ui_user/features/caching/clients/sentry_user_cache_client.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_configuration_cache.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_user_cache.dart';
import 'package:tmail_ui_user/features/caching/exceptions/local_storage_exception.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';

class SentryConfigurationCacheManager {
  static const int _maxReportingConsentUpdateAttempts = 2;

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

  Future<SentryConfigurationCache?> updateSentryReportingAllowed(
    bool isReportingAllowed,
  ) async {
    for (var attempt = 1;
        attempt <= _maxReportingConsentUpdateAttempts;
        attempt++) {
      try {
        final current = await getSentryConfiguration();
        final updated = current.copyWith(
          isReportingAllowed: isReportingAllowed,
        );
        await saveSentryConfiguration(updated);
        return updated;
      } catch (e) {
        logWarning(
          'SentryConfigurationCacheManager::updateSentryReportingAllowed: '
          'attempt $attempt failed: $e',
        );
      }
    }

    if (isReportingAllowed) return null;

    await clearSentryConfiguration();
    return null;
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
    Object? configurationClearError;
    StackTrace? configurationClearStackTrace;
    try {
      await _configurationCacheClient.clearAllData();
    } catch (e, st) {
      configurationClearError = e;
      configurationClearStackTrace = st;
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

    if (configurationClearError != null &&
        configurationClearStackTrace != null) {
      Error.throwWithStackTrace(
        configurationClearError,
        configurationClearStackTrace,
      );
    }
  }
}
