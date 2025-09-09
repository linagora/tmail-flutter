import 'package:flutter_test/flutter_test.dart';
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

    test('replaces both encoded placeholders', () {
      const template = 'https://%7BlocalPart%7D.%7BdomainName%7D/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        localPart: 'david',
        domainName: 'mysite.com',
      );
      expect(url, 'https://david.mysite.com/paywall');
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

    test('template with repeated placeholders', () {
      const template =
          'https://{localPart}.{domainName}/{localPart}-{domainName}/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        localPart: 'anna',
        domainName: 'repeat.com',
      );
      expect(url, 'https://anna.repeat.com/anna-repeat.com/paywall');
    });

    test('template with repeated encoded placeholders', () {
      const template =
          'https://%7BlocalPart%7D.%7BdomainName%7D/%7BlocalPart%7D-%7BdomainName%7D/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        localPart: 'zoe',
        domainName: 'repeat.org',
      );
      expect(url, 'https://zoe.repeat.org/zoe-repeat.org/paywall');
    });

    test('template with mix of raw and encoded repeated placeholders', () {
      const template =
          'https://{localPart}.%7BdomainName%7D/{localPart}-%7BdomainName%7D/paywall';
      final url = PaywallUtils.buildPaywallUrlFromTemplate(
        template: template,
        localPart: 'mix',
        domainName: 'combo.net',
      );
      expect(url, 'https://mix.combo.net/mix-combo.net/paywall');
    });
  });
}
