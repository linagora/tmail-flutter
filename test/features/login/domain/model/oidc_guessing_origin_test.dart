import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/login/domain/model/oidc_guessing_origin.dart';

void main() {
  group('OidcGuessingOrigin enum', () {
    test('url() returns correct URL for empty origin', () {
      const email = 'user@example.com';
      const origin = OidcGuessingOrigin.empty;
      expect(origin.url(email), 'https://example.com');
    });

    test('url() returns correct URL for autoDiscover origin', () {
      const email = 'user@example.com';
      const origin = OidcGuessingOrigin.autoDiscover;
      expect(origin.url(email), 'https://autodiscover.example.com');
    });

    test('url() returns correct URL for jmap origin', () {
      const email = 'user@example.com';
      const origin = OidcGuessingOrigin.jmap;
      expect(origin.url(email), 'https://jmap.example.com');
    });

    test('url() throws error for invalid email', () {
      const email = 'invalid_email@@example.com';
      const origin = OidcGuessingOrigin.empty;
      expect(() => origin.url(email), throwsArgumentError);
    });
    
    test('url() returns correct URL for jmap origin with quoted local part', () {
      const email = '"user"@example.com';
      const origin = OidcGuessingOrigin.jmap;
      expect(origin.url(email), 'https://jmap.example.com');
    });
    
    test('url() returns correct URL for jmap origin with quoted local part containing @', () {
      const email = '"user@local"@example.com';
      const origin = OidcGuessingOrigin.jmap;
      expect(origin.url(email), 'https://jmap.example.com');
    });
  });
}