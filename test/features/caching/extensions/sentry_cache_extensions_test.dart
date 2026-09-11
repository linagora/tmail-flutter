import 'package:core/utils/sentry/sentry_config.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/caching/extensions/sentry_cache_extensions.dart';

void main() {
  test('preserves reporting consent through the background cache', () {
    final config = SentryConfig(
      dsn: 'https://test@sentry.io/123',
      environment: 'test',
      release: '1.0.0',
      isAvailable: true,
      isReportingAllowed: false,
    );

    final restored = config.toSentryConfigurationCache().toSentryConfig();

    expect(restored.isReportingAllowed, isFalse);
  });
}
