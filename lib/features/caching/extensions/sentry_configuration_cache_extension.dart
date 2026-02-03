import 'package:core/utils/sentry/sentry_config.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_configuration_cache.dart';

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
    );
  }
}
