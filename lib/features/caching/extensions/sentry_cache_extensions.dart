import 'package:core/utils/sentry/sentry_config.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_configuration_cache.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_user_cache.dart';

extension SentryConfigExtension on SentryConfig {
  SentryConfigurationCache toSentryConfigurationCache() {
    return SentryConfigurationCache(
      dsn: dsn,
      environment: environment,
      release: release,
      isAvailable: isAvailable,
      tracesSampleRate: tracesSampleRate,
      profilesSampleRate: profilesSampleRate,
      sessionSampleRate: sessionSampleRate,
      onErrorSampleRate: onErrorSampleRate,
      enableLogs: enableLogs,
      enableFramesTracking: enableFramesTracking,
      isDebug: isDebug,
      attachScreenshot: attachScreenshot,
      dist: dist,
    );
  }
}

extension SentryConfigurationCacheExtension on SentryConfigurationCache {
  SentryConfig toSentryConfig() {
    return SentryConfig(
      dsn: dsn,
      environment: environment,
      release: release,
      isAvailable: isAvailable,
      tracesSampleRate: tracesSampleRate,
      profilesSampleRate: profilesSampleRate,
      sessionSampleRate: sessionSampleRate,
      onErrorSampleRate: onErrorSampleRate,
      enableLogs: enableLogs,
      enableFramesTracking: enableFramesTracking,
      isDebug: isDebug,
      attachScreenshot: attachScreenshot,
      dist: dist,
    );
  }
}

extension SentryUserExtension on SentryUser {
  SentryUserCache toSentryUserCache() {
    return SentryUserCache(
      id: id ?? '',
      name: name ?? '',
      username: username ?? '',
      email: email ?? '',
    );
  }
}

extension SentryUserCacheExtension on SentryUserCache {
  SentryUser toSentryUser() {
    return SentryUser(
      id: id.isEmpty ? null : id,
      name: name.isEmpty ? null : name,
      username: username.isEmpty ? null : username,
      email: email.isEmpty ? null : email,
    );
  }
}
