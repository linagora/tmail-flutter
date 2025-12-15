import 'package:core/utils/application_manager.dart';
import 'package:core/utils/build_utils.dart';
import 'package:core/utils/config/env_loader.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  // Enable logs to be sent to Sentry. To use Sentry.logger.fmt
  final bool enableLogs;

  // Debug logs during development
  final bool isDebug;

  // Automatically attaches a screenshot when capturing an error or exception.
  final bool attachScreenshot;

  // Check if Sentry is available
  final bool isAvailable;

  SentryConfig({
    required this.dsn,
    required this.environment,
    required this.release,
    this.tracesSampleRate = 1.0,
    this.profilesSampleRate = 1.0,
    this.enableLogs = true,
    this.isDebug = BuildUtils.isDebugMode,
    this.attachScreenshot = false,
    this.isAvailable = false,
  });

  /// Load configuration from an env file.
  static Future<SentryConfig> load() async {
    await EnvLoader.loadConfigFromEnv();

    final sentryAvailable = dotenv.get('SENTRY_ENABLED', fallback: 'false');

    final isAvailable = sentryAvailable == 'true';
    final sentryDSN = dotenv.get('SENTRY_DSN', fallback: '');
    final sentryEnvironment = dotenv.get('SENTRY_ENVIRONMENT', fallback: '');

    if (!isAvailable) {
      throw Exception('Sentry is not available');
    }

    if (sentryDSN.trim().isEmpty || sentryEnvironment.trim().isEmpty) {
      throw Exception('Sentry configuration is missing');
    }

    final appVersion = await ApplicationManager().getVersion();

    return SentryConfig(
      dsn: sentryDSN,
      environment: sentryEnvironment,
      release: appVersion,
      isAvailable: isAvailable,
    );
  }
}
