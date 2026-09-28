import 'package:core/utils/sentry/sentry_reporting_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SentryReportingPolicy', () {
    test('resolves user consent before override and configuration', () {
      final policy = SentryReportingPolicy(
        isAllowedByConfiguration: false,
      );
      policy.setDefaultOverride(true);
      policy.setUserConsent(false);

      expect(policy.isAllowed, isFalse);

      policy.setUserConsent(null);
      expect(policy.isAllowed, isTrue);

      policy.clearDefaultOverride();
      expect(policy.isAllowed, isFalse);
    });

    test('starts denied until ecosystem or server consent is supplied', () {
      final policy = SentryReportingPolicy();

      expect(policy.isAllowed, isFalse);
      expect(policy.shouldRun, isFalse);

      policy.setDefaultOverride(true);
      expect(policy.shouldRun, isTrue);

      policy.clearDefaultOverride();
      expect(policy.shouldRun, isFalse);
    });

    test('suspends reporting without changing the resolved permission', () {
      final policy = SentryReportingPolicy(isAllowedByConfiguration: true);

      expect(policy.isAllowed, isTrue);
      expect(policy.shouldRun, isTrue);

      expect(policy.suspend(), isTrue);
      expect(policy.suspend(), isFalse);
      expect(policy.isAllowed, isTrue);
      expect(policy.shouldRun, isFalse);

      expect(policy.resume(), isTrue);
      expect(policy.resume(), isFalse);
      expect(policy.shouldRun, isTrue);
    });
  });
}
