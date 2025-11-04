import 'package:core/utils/build_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

/// Holds configuration values for initializing Sentry.
class SentryConfig {
  // DSN (Data Source Name) endpoint for the Sentry project
  final String dsn;

  // Running environment (production/staging/dev)
  final String environment;

  // Current app release version
  final String release;

  // // Performance monitoring: Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing
  final double tracesSampleRate;

  // Optional profiling
  final double profilesSampleRate;

  // Enable logs to be sent to Sentry
  final bool enableLogs;

  // Debug logs during development
  final bool isDebug;

  SentryConfig({
    required this.dsn,
    required this.environment,
    required this.release,
    this.tracesSampleRate = 1.0,
    this.profilesSampleRate = 1.0,
    this.enableLogs = true,
    this.isDebug = BuildUtils.isDebugMode,
  });

  /// Load configuration from an env file.
  static Future<SentryConfig> load() async {
    await AppUtils.loadConfigFromEnv();

    final sentryAvailable =
        dotenv.get('SENTRY_AVAILABLE', fallback: 'unsupported');

    if (sentryAvailable != 'supported') {
      throw Exception('Sentry is not available');
    }

    await AppUtils.loadSentryConfigFileToEnv();

    final sentryDSN = dotenv.get('SENTRY_DSN', fallback: '');
    final sentryEnvironment = dotenv.get('SENTRY_ENVIRONMENT', fallback: '');

    if (sentryDSN.trim().isEmpty || sentryEnvironment.trim().isEmpty) {
      throw Exception('Sentry configuration is missing');
    }

    final appVersion = await AppUtils.getAppVersion();

    return SentryConfig(
      dsn: sentryDSN,
      environment: sentryEnvironment,
      release: appVersion,
    );
  }
}
