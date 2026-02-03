import 'package:core/utils/sentry/sentry_config.dart';
import 'package:tmail_ui_user/features/caching/entries/sentry_configuration_cache.dart';

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
    );
  }
}
