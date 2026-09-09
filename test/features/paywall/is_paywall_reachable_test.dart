import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_utils.dart';

void main() {
  group('PaywallUtils.buildWorkplacePaywallUrl', () {
    final workplaceCases = [
      (
        description: 'bare FQDN',
        input: 'workplace.domain.tld',
        expected: 'https://workplace.domain.tld/settings/premium',
      ),
      (
        description: 'HTTPS URL',
        input: 'https://workplace.domain.tld',
        expected: 'https://workplace.domain.tld/settings/premium',
      ),
      (
        description: 'uppercase HTTPS scheme',
        input: 'HTTPS://workplace.domain.tld',
        expected: 'https://workplace.domain.tld/settings/premium',
      ),
      (
        description: 'trimmed FQDN',
        input: '  workplace.domain.tld  ',
        expected: 'https://workplace.domain.tld/settings/premium',
      ),
      (description: 'null value', input: null, expected: ''),
      (description: 'blank value', input: '   ', expected: ''),
      (description: 'localhost', input: 'localhost', expected: ''),
      (
        description: 'HTTP URL',
        input: 'http://workplace.domain.tld',
        expected: '',
      ),
      (
        description: 'unsupported scheme',
        input: 'httpx://workplace.domain.tld',
        expected: '',
      ),
      (
        description: 'URL containing user info',
        input: 'https://user@workplace.domain.tld',
        expected: '',
      ),
    ];

    for (final workplaceCase in workplaceCases) {
      test('should handle ${workplaceCase.description}', () {
        expect(
          PaywallUtils.buildWorkplacePaywallUrl(workplaceCase.input),
          workplaceCase.expected,
        );
      });
    }
  });

  group('PaywallUtils.isValidPaywallUrl', () {
    final paywallUrlCases = [
      (
        description: 'absolute HTTPS URL',
        input: 'https://domain.tld/paywall',
        expected: true,
      ),
      (
        description: 'uppercase HTTPS scheme',
        input: 'HTTPS://domain.tld/paywall',
        expected: true,
      ),
      (
        description: 'HTTPS URL containing a fragment route',
        input: 'https://domain.tld/#/premium',
        expected: true,
      ),
      (description: 'null value', input: null, expected: false),
      (description: 'blank value', input: '   ', expected: false),
      (
        description: 'HTTP URL',
        input: 'http://domain.tld/paywall',
        expected: false,
      ),
      (
        description: 'JavaScript URL',
        input: 'javascript:alert(1)',
        expected: false,
      ),
      (description: 'relative URL', input: '/paywall', expected: false),
      (
        description: 'URL without a host',
        input: 'https:///paywall',
        expected: false,
      ),
      (
        description: 'URL without a fully-qualified host',
        input: 'https://localhost/paywall',
        expected: false,
      ),
      (
        description: 'URL containing user info',
        input: 'https://user@domain.tld/paywall',
        expected: false,
      ),
    ];

    for (final paywallUrlCase in paywallUrlCases) {
      test('should handle ${paywallUrlCase.description}', () {
        expect(
          PaywallUtils.isValidPaywallUrl(paywallUrlCase.input),
          paywallUrlCase.expected,
        );
      });
    }
  });
}
