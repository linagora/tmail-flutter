import 'package:core/utils/application_manager.dart';
import 'package:core/utils/build_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Holds configuration values for initializing Sentry.
class SentryConfig {
  static const String enabledEnvKey = 'SENTRY_ENABLED';
  static const String dsnEnvKey = 'SENTRY_DSN';
  static const String environmentEnvKey = 'SENTRY_ENVIRONMENT';

  // DSN (Data Source Name) endpoint for the Sentry project
  final String dsn;

  // Running environment (production/staging/dev)
  final String environment;

  // Current app release version
  final String release;

  // Performance monitoring: Percentage of transactions captured for tracing.
  // Keep low in production (e.g. 0.1 = 10%) to avoid quota exhaustion and latency overhead.
  final double tracesSampleRate;

  // Optional profiling: percentage of sampled transactions that are also profiled.
  // Keep low in production (e.g. 0.1 = 10%) — profiling adds significant CPU overhead.
  final double profilesSampleRate;

  // Enable logs to be sent to Sentry. To use Sentry.logger.fmt
  final bool enableLogs;

  // Debug logs during development
  final bool isDebug;

  // Automatically attaches a screenshot when capturing an error or exception.
  final bool attachScreenshot;

  // Check if Sentry is available
  final bool isAvailable;

  // Whether this process may send reports. Persisted for background workers
  // that cannot load the account's server settings before Sentry starts.
  final bool isReportingAllowed;

  // The distribution version of the release.
  // In this project, it represents the Git SHA passed via `--dart-define=SENTRY_DIST`.
  // This must match the `--dist` parameter used when uploading source maps to Sentry.
  final String? dist;

  // Release Health: The sampling rate for sessions (0.0 to 1.0). Defines the percentage of sessions to send.
  final double? sessionSampleRate;

  // Error tracking: The sampling rate for errors (0.0 to 1.0). If set to 0.1, only 10% of errors are sent.
  final double? onErrorSampleRate;

  // Performance: Tracks UI rendering performance (slow and frozen frames).
  final bool enableFramesTracking;

  SentryConfig({
    required this.dsn,
    required this.environment,
    required this.release,
    this.tracesSampleRate = 0.1,
    this.profilesSampleRate = 0.1,
    this.sessionSampleRate,
    this.onErrorSampleRate,
    this.enableLogs = true,
    this.enableFramesTracking = true,
    this.isDebug = BuildUtils.isDebugMode,
    this.attachScreenshot = false,
    this.isAvailable = false,
    this.isReportingAllowed = false,
    this.dist,
  });

  SentryConfig withReportingAllowed(bool allowed) => SentryConfig(
        dsn: dsn,
        environment: environment,
        release: release,
        tracesSampleRate: tracesSampleRate,
        profilesSampleRate: profilesSampleRate,
        sessionSampleRate: sessionSampleRate,
        onErrorSampleRate: onErrorSampleRate,
        enableLogs: enableLogs,
        enableFramesTracking: enableFramesTracking,
        isDebug: isDebug,
        attachScreenshot: attachScreenshot,
        isAvailable: isAvailable,
        isReportingAllowed: allowed,
        dist: dist,
      );

  /// Any non-empty Sentry env value keeps web configuration env-owned. A
  /// disabled or incomplete configuration cannot initialize Sentry or use
  /// ecosystem fallback; fallback applies only when all three values are
  /// absent or blank.
  static bool get hasEnvironmentConfiguration {
    if (!dotenv.isInitialized) return false;
    final environment = dotenv.env;
    return const [enabledEnvKey, dsnEnvKey, environmentEnvKey].any(
      (key) => environment[key]?.trim().isNotEmpty == true,
    );
  }

  /// Loads configuration from loaded environment variables.
  static Future<SentryConfig?> load() async {
    // Note: Ensure EnvLoader.loadEnvFile() is called in main.dart before this.
    if (!dotenv.isInitialized) return null;
    final isEnabled = dotenv.get(enabledEnvKey, fallback: 'false') == 'true';
    if (!isEnabled) return null;

    final sentryDSN = dotenv.get(dsnEnvKey, fallback: '');
    final sentryEnvironment = dotenv.get(environmentEnvKey, fallback: '');

    final isConfigValid = sentryDSN.trim().isNotEmpty
        && sentryEnvironment.trim().isNotEmpty;
    if (!isConfigValid) return null;

    final isWeb = PlatformInfo.isWeb;

    final release = await _resolveRelease();

    const sentryDist = String.fromEnvironment('SENTRY_DIST');
    logTrace(
      'SentryConfig::load: sentryDist is $sentryDist, '
      'release is $release',
      webConsoleEnabled: true,
    );

    return SentryConfig(
      dsn: sentryDSN,
      environment: sentryEnvironment,
      release: release,
      isAvailable: true,
      isReportingAllowed: isWeb,
      dist: sentryDist.isNotEmpty ? sentryDist : null,
    );
  }

  /// Resolves the Sentry release string.
  ///
  /// Priority:
  /// 1. `--dart-define=SENTRY_RELEASE=<version>` injected at build time by
  ///    Fastlane/CI — guarantees the same string the CI uses to upload symbols.
  /// 2. `PackageInfo.version` as fallback (local dev / non-release builds).
  ///
  /// Why dart-define takes priority: iOS CFBundleShortVersionString strips
  /// pre-release suffixes (e.g. "0.28.3-rc09" → "0.28.3"), so PackageInfo
  /// returns a different value than what CI tags the symbols with.
  static Future<String> _resolveRelease() async {
    const dartDefineRelease = String.fromEnvironment('SENTRY_RELEASE');
    if (dartDefineRelease.isNotEmpty) return dartDefineRelease;
    return ApplicationManager().getAppVersion();
  }

  static const String sentryConfigKeyChain = 'sentry_config_data';

  Map<String, dynamic> toJson() {
    return {
      'dsn': dsn,
      'environment': environment,
      'release': release,
      if (dist != null) 'dist': dist,
      'tracesSampleRate': tracesSampleRate,
      'profilesSampleRate': profilesSampleRate,
      'sessionSampleRate': sessionSampleRate,
      'onErrorSampleRate': onErrorSampleRate,
      'enableLogs': enableLogs,
      'isDebug': isDebug,
      'attachScreenshot': attachScreenshot,
      'isAvailable': isAvailable,
      'isReportingAllowed': isReportingAllowed,
      'enableFramesTracking': enableFramesTracking,
    };
  }
}
