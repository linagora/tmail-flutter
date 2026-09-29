import 'package:core/utils/application_manager.dart';
import 'package:core/utils/platform_info.dart';
import 'package:core/utils/sentry/sentry_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  test('runtime configuration starts with reporting denied', () {
    final config = SentryConfig(
      dsn: 'https://public@example.com/1',
      environment: 'staging',
      release: '1.2.3',
      isAvailable: true,
    );

    expect(config.isReportingAllowed, isFalse);
  });

  test('any non-empty Sentry env value prevents ecosystem fallback',
      () async {
    addTearDown(dotenv.clean);

    expect(SentryConfig.hasEnvironmentConfiguration, isFalse);
    expect(await SentryConfig.load(), isNull);

    dotenv.testLoad();
    expect(SentryConfig.hasEnvironmentConfiguration, isFalse);

    dotenv.testLoad(
      mergeWith: {
        'SENTRY_ENABLED': '',
        'SENTRY_DSN': '  ',
        'SENTRY_ENVIRONMENT': '',
      },
    );
    expect(SentryConfig.hasEnvironmentConfiguration, isFalse);

    dotenv.testLoad(mergeWith: {'SENTRY_ENABLED': 'false'});
    expect(SentryConfig.hasEnvironmentConfiguration, isTrue);
    expect(await SentryConfig.load(), isNull);

    dotenv.testLoad(mergeWith: {'SENTRY_ENABLED': 'true'});
    expect(SentryConfig.hasEnvironmentConfiguration, isTrue);
    expect(await SentryConfig.load(), isNull);

    dotenv.testLoad(mergeWith: {'SENTRY_DSN': 'https://env@example.com/1'});
    expect(SentryConfig.hasEnvironmentConfiguration, isTrue);
    expect(await SentryConfig.load(), isNull);

    dotenv.testLoad(mergeWith: {'SENTRY_ENVIRONMENT': 'staging'});
    expect(SentryConfig.hasEnvironmentConfiguration, isTrue);
    expect(await SentryConfig.load(), isNull);
  });

  test('web requires SENTRY_ENABLED=true with both env credentials',
      () async {
    _prepareWebSentryEnvironment();

    dotenv.testLoad(mergeWith: {
      SentryConfig.enabledEnvKey: 'true',
      SentryConfig.dsnEnvKey: 'https://env@example.com/1',
      SentryConfig.environmentEnvKey: 'staging',
    });

    final config = await SentryConfig.load();
    expect(
      (
        config?.isAvailable,
        config?.isReportingAllowed,
        config?.dsn,
        config?.environment,
      ),
      (true, true, 'https://env@example.com/1', 'staging'),
    );
  });

  test('web rejects disabled or missing SENTRY_ENABLED with env credentials',
      () async {
    _prepareWebSentryEnvironment();

    for (final enabled in ['false', '', null]) {
      dotenv.testLoad(mergeWith: {
        if (enabled != null) SentryConfig.enabledEnvKey: enabled,
        SentryConfig.dsnEnvKey: 'https://env@example.com/1',
        SentryConfig.environmentEnvKey: 'staging',
      });

      expect(SentryConfig.hasEnvironmentConfiguration, isTrue);
      expect(await SentryConfig.load(), isNull);
    }
  });

  test('withReportingAllowed changes only reporting consent', () {
    final config = SentryConfig(
      dsn: 'https://public@example.com/1',
      environment: 'staging',
      release: '1.2.3',
      tracesSampleRate: 0.2,
      profilesSampleRate: 0.3,
      sessionSampleRate: 0.4,
      onErrorSampleRate: 0.5,
      enableLogs: false,
      enableFramesTracking: false,
      isDebug: true,
      attachScreenshot: true,
      isAvailable: true,
      isReportingAllowed: true,
      dist: 'abc123',
    );

    final updated = config.withReportingAllowed(false);

    expect(updated.dsn, config.dsn);
    expect(updated.environment, config.environment);
    expect(updated.release, config.release);
    expect(updated.tracesSampleRate, config.tracesSampleRate);
    expect(updated.profilesSampleRate, config.profilesSampleRate);
    expect(updated.sessionSampleRate, config.sessionSampleRate);
    expect(updated.onErrorSampleRate, config.onErrorSampleRate);
    expect(updated.enableLogs, config.enableLogs);
    expect(updated.enableFramesTracking, config.enableFramesTracking);
    expect(updated.isDebug, config.isDebug);
    expect(updated.attachScreenshot, config.attachScreenshot);
    expect(updated.isAvailable, config.isAvailable);
    expect(updated.dist, config.dist);
    expect(updated.isReportingAllowed, isFalse);
  });
}

void _prepareWebSentryEnvironment() {
  PlatformInfo.isTestingForWeb = true;
  addTearDown(() => PlatformInfo.isTestingForWeb = false);
  addTearDown(dotenv.clean);
  PackageInfo.setMockInitialValues(
    appName: 'Twake Mail',
    packageName: 'com.example.twake',
    version: '1.0.0',
    buildNumber: '1',
    buildSignature: '',
  );
  ApplicationManager().clearCache();
  addTearDown(ApplicationManager().clearCache);
}
