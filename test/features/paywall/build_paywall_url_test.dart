import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_utils.dart';

void main() {
  group('PaywallUtils.buildPaywallUrlFromTemplate', () {
    // --- Raw placeholder cases ---
    test('replaces raw {localPart} and {domainName}', () {
      const template = 'https://{localPart}.{domainName}/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        localPart: 'alice',
        domainName: 'example.com',
      );
      expect(url, 'https://alice.example.com/paywall');
    });

    test('replaces raw {domainPart} as an alias of {domainName}', () {
      const template = 'https://{localPart}.{domainPart}/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        localPart: 'alice',
        domainName: 'example.com',
      );
      expect(url, 'https://alice.example.com/paywall');
    });

    test('removes {localPart} when null', () {
      const template = 'https://{localPart}.{domainName}/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        domainName: 'example.com',
      );
      expect(url, 'https://.example.com/paywall');
    });

    test('removes {domainName} when null', () {
      const template = 'https://{localPart}.{domainName}/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        localPart: 'bob',
      );
      expect(url, 'https://bob./paywall');
    });

    test('removes both {localPart} and {domainName} when both null', () {
      const template = 'https://{localPart}.{domainName}/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(template: template);
      expect(url, 'https://./paywall');
    });

    // --- Encoded placeholder cases ---
    test('replaces encoded %7BlocalPart%7D', () {
      const template = 'https://%7BlocalPart%7D.twake.app/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        localPart: 'charlie',
      );
      expect(url, 'https://charlie.twake.app/paywall');
    });

    test('replaces encoded %7BdomainName%7D', () {
      const template = 'https://account.%7BdomainName%7D/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        domainName: 'test.org',
      );
      expect(url, 'https://account.test.org/paywall');
    });

    test('replaces encoded %7BdomainPart%7D as an alias of domainName', () {
      const template = 'https://account.%7BdomainPart%7D/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        domainName: 'test.org',
      );
      expect(url, 'https://account.test.org/paywall');
    });

    test('removes encoded placeholders when null', () {
      const template = 'https://%7BlocalPart%7D.%7BdomainName%7D/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(template: template);
      expect(url, 'https://./paywall');
    });

    // --- Mixed raw + encoded ---
    test('handles raw {localPart} and encoded %7BdomainName%7D together', () {
      const template = 'https://{localPart}.%7BdomainName%7D/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        localPart: 'eve',
        domainName: 'hybrid.com',
      );
      expect(url, 'https://eve.hybrid.com/paywall');
    });

    test('handles encoded %7BlocalPart%7D and raw {domainName} together', () {
      const template = 'https://%7BlocalPart%7D.{domainName}/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        localPart: 'frank',
        domainName: 'hybrid.org',
      );
      expect(url, 'https://frank.hybrid.org/paywall');
    });

    // --- No placeholders ---
    test('keeps template unchanged if no placeholders', () {
      const template = 'https://static.twake.app/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        localPart: 'ghost',
        domainName: 'ignored.com',
      );
      expect(url, 'https://static.twake.app/paywall');
    });

    // --- Edge cases ---
    test('empty template returns empty string', () {
      const template = '';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        localPart: 'x',
        domainName: 'y.com',
      );
      expect(url, '');
    });

    test('malformed template returns null', () {
      expect(
        PaywallUtils.buildPaywallUrlFromTemplate(
          template: 'https://domain.tld/{localPart',
          localPart: 'alice',
        ),
        isNull,
      );
    });

    test('template with only {localPart}', () {
      const template = '{localPart}';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        localPart: 'single',
      );
      expect(url, 'single');
    });

    test('template with only {domainName}', () {
      const template = '{domainName}';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        domainName: 'onedomain.com',
      );
      expect(url, 'onedomain.com');
    });

    final multiplePlaceholderCases = <({
      String description,
      String template,
      String localPart,
      String domainName,
      String expected,
    })>[
      (
        description: 'replaces both encoded placeholders',
        template: 'https://%7BlocalPart%7D.%7BdomainName%7D/paywall',
        localPart: 'david',
        domainName: 'mysite.com',
        expected: 'https://david.mysite.com/paywall',
      ),
      (
        description: 'template with repeated placeholders',
        template:
            'https://{localPart}.{domainName}/{localPart}-{domainName}/paywall',
        localPart: 'anna',
        domainName: 'repeat.com',
        expected: 'https://anna.repeat.com/anna-repeat.com/paywall',
      ),
      (
        description: 'template with repeated encoded placeholders',
        template:
            'https://%7BlocalPart%7D.%7BdomainName%7D/%7BlocalPart%7D-%7BdomainName%7D/paywall',
        localPart: 'zoe',
        domainName: 'repeat.org',
        expected: 'https://zoe.repeat.org/zoe-repeat.org/paywall',
      ),
      (
        description:
            'template with mix of raw and encoded repeated placeholders',
        template:
            'https://{localPart}.%7BdomainName%7D/{localPart}-%7BdomainName%7D/paywall',
        localPart: 'mix',
        domainName: 'combo.net',
        expected: 'https://mix.combo.net/mix-combo.net/paywall',
      ),
    ];

    for (final testCase in multiplePlaceholderCases) {
      test(testCase.description, () {
        final url = PaywallUtils.buildPaywallUrlFromTemplate(
          template: testCase.template,
          localPart: testCase.localPart,
          domainName: testCase.domainName,
        );
        expect(url, testCase.expected);
      });
    }

    test('workplace FQDN fallback template resolves {localPart} only', () {
      const template = '{localPart}.twake.linagora.com';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        localPart: 'alice',
      );
      expect(url, 'alice.twake.linagora.com');
    });
  });

  group('PaywallUrlPattern.resolveQualifiedUrl', () {
    test('returns null when a placeholder cannot be filled', () {
      expect(
        PaywallUrlPattern('{localPart}.twake.linagora.com')
            .resolveQualifiedUrl(ownerEmail: 'alice'),
        isNull,
      );
    });

    test('resolves a literal pattern without a usable owner email', () {
      expect(
        PaywallUrlPattern('workplace.example.com').resolveQualifiedUrl(ownerEmail: ''),
        'workplace.example.com',
      );
    });

    test('fills the placeholder from a parseable address', () {
      expect(
        PaywallUrlPattern('{localPart}.twake.linagora.com')
            .resolveQualifiedUrl(ownerEmail: 'john.doe@corp.tld'),
        'johndoe.twake.linagora.com',
      );
    });

    test('fills {domainName} from the explicit domain when given', () {
      expect(
        PaywallUrlPattern('https://paywall.domain.tld/{localPart}/{domainName}')
            .resolveQualifiedUrl(
                ownerEmail: 'alice@corp.tld', domainName: 'other.tld'),
        'https://paywall.domain.tld/alice/other.tld',
      );
    });

    test('fills {domainPart} from the explicit domain when given', () {
      expect(
        PaywallUrlPattern('https://paywall.domain.tld/{localPart}/{domainPart}')
            .resolveQualifiedUrl(
                ownerEmail: 'alice@corp.tld', domainName: 'other.tld'),
        'https://paywall.domain.tld/alice/other.tld',
      );
    });

    test('returns null when the owner email cannot fill {localPart}', () {
      expect(
        PaywallUrlPattern('https://paywall.domain.tld/{localPart}/{domainName}')
            .resolveQualifiedUrl(ownerEmail: '', domainName: 'domain.tld'),
        isNull,
      );
    });
  });
}
