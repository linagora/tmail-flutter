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
      (
        description: 'unparseable URI',
        input: 'https://[invalid',
        expected: '',
      ),
      (
        description: 'URL without a host',
        input: 'https:///settings',
        expected: '',
      ),
      // Only the host survives: the caller-supplied path, query and fragment are
      // replaced by the fixed premium route.
      (
        description: 'URL carrying a path, query and fragment',
        input: 'https://workplace.domain.tld/foo?x=1#fragment',
        expected: 'https://workplace.domain.tld/settings/premium',
      ),
      (
        description: 'uppercase host',
        input: 'HTTPS://WORKPLACE.DOMAIN.TLD',
        expected: 'https://workplace.domain.tld/settings/premium',
      ),
      // A Workplace served on a non-default port must keep that port, otherwise
      // the CTA silently navigates to a different origin.
      (
        description: 'explicit port',
        input: 'https://workplace.domain.tld:8443',
        expected: 'https://workplace.domain.tld:8443/settings/premium',
      ),
      // An IP literal passes the FQDN check because that check only counts
      // dot-separated parts. Pinned as current behaviour, not as an endorsement.
      (
        description: 'IP literal host',
        input: 'https://192.168.1.1',
        expected: 'https://192.168.1.1/settings/premium',
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
      (
        description: 'unparseable URI',
        input: 'https://[invalid',
        expected: false,
      ),
      (
        description: 'URL padded with whitespace',
        input: '  https://domain.tld/paywall  ',
        expected: true,
      ),
      // Ports are accepted here even though buildWorkplacePaywallUrl drops them.
      (
        description: 'URL with an explicit port',
        input: 'https://domain.tld:8443/paywall',
        expected: true,
      ),
      // Both cases clear the FQDN check, which only counts dot-separated parts.
      (
        description: 'IP literal host',
        input: 'https://192.168.1.1/paywall',
        expected: true,
      ),
      (
        description: 'trailing-dot host',
        input: 'https://domain.tld./paywall',
        expected: true,
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
