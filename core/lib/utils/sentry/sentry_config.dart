import 'package:core/utils/application_manager.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Holds configuration values for initializing Sentry.
class SentryConfig {
  // DSN (Data Source Name) endpoint for the Sentry project
  final String dsn;

  // Running environment (production/staging/dev)
  final String environment;

  // Current app release version
  final String release;

  // Performance monitoring: Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing
  final double tracesSampleRate;

  // Optional profiling
  final double profilesSampleRate;

  // Enable logs to be sent to Sentry. To use Sentry.logger.fmt
  final bool enableLogs;

  // Debug logs during development
  final bool isDebug;

  // Automatically attaches a screenshot when capturing an error or exception.
  final bool attachScreenshot;

  // Check if Sentry is available
  final bool isAvailable;

  // Release Health: The sampling rate for sessions (0.0 to 1.0). Defines the percentage of sessions to send.
  final double sessionSampleRate;

  // Error tracking: The sampling rate for errors (0.0 to 1.0). If set to 0.1, only 10% of errors are sent.
  final double onErrorSampleRate;

  // Performance: Tracks UI rendering performance (slow and frozen frames).
  final bool enableFramesTracking;

  SentryConfig({
    required this.dsn,
    required this.environment,
    required this.release,
    this.tracesSampleRate = 1.0,
    this.profilesSampleRate = 1.0,
    this.sessionSampleRate = 1.0,
    this.onErrorSampleRate = 1.0,
    this.enableLogs = true,
    this.enableFramesTracking = true,
    this.isDebug = BuildUtils.isDebugMode,
    this.attachScreenshot = false,
    this.isAvailable = false,
  });

  /// Loads configuration from loaded environment variables.
  static Future<SentryConfig?> load() async {
    // Note: Ensure EnvLoader.loadEnvFile() is called in main.dart before this.
    final sentryAvailable = dotenv.get('SENTRY_ENABLED', fallback: 'false');

    final isAvailable = sentryAvailable == 'true';
    final sentryDSN = dotenv.get('SENTRY_DSN', fallback: '');
    final sentryEnvironment = dotenv.get('SENTRY_ENVIRONMENT', fallback: '');

    if (!isAvailable ||
        sentryDSN.trim().isEmpty ||
        sentryEnvironment.trim().isEmpty) {
      return null;
    }

    final appVersion = await ApplicationManager().getAppVersion();

    return SentryConfig(
      dsn: sentryDSN,
      environment: sentryEnvironment,
      release: appVersion,
      isAvailable: isAvailable,
    );
  }

  static const String sentryConfigKeyChain = 'sentry_config_data';

  Map<String, dynamic> toJson() {
    return {
      'dsn': dsn,
      'environment': environment,
      'release': release,
      'tracesSampleRate': tracesSampleRate,
      'profilesSampleRate': profilesSampleRate,
      'sessionSampleRate': sessionSampleRate,
      'onErrorSampleRate': onErrorSampleRate,
      'enableLogs': enableLogs,
      'isDebug': isDebug,
      'attachScreenshot': attachScreenshot,
      'isAvailable': isAvailable,
      'enableFramesTracking': enableFramesTracking,
    };
  }
}