import 'package:core/utils/external_link_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExternalLinkPolicy.canLaunchFromContent', () {
    for (final url in const [
      'https://example.com',
      'http://example.com/path',
      'HTTPS://EXAMPLE.COM',
      'tel:+33123456789',
      'mailto:someone@example.com',
      'sms:+33123456789',
      'webcal://calendar.example/feed.ics',
      'geo:48.85,2.35',
    ]) {
      test('SHOULD allow $url', () {
        expect(ExternalLinkPolicy.canLaunchFromContent(Uri.parse(url)), isTrue);
      });
    }

    for (final url in const [
      'twakemail.mobile://openApp?jmapUrl=https://evil.example',
      'teammail.mobile://oauthredirect',
      'intent://scan/#Intent;scheme=zxing;end',
      'file:///etc/hosts',
      'javascript:alert(1)',
      'market://details?id=x',
    ]) {
      test('SHOULD refuse $url', () {
        expect(ExternalLinkPolicy.canLaunchFromContent(Uri.parse(url)), isFalse);
      });
    }
  });
}
