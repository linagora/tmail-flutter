import 'package:core/utils/sentry/sentry_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
