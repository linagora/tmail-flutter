import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';

void main() {
  group('AppUtils::isEmailLocalhost', () {
    group('Valid localhost email addresses', () {
      final validEmails = [
        EmailAddress('userName', 'alice@localhost'),
        EmailAddress('userName', 'bob@localhost'),
        EmailAddress('userName', '123@localhost'),
        EmailAddress('userName', 'alic.2312e@localhost'),
        EmailAddress('userName', 'alice_linagora@localhost'),
        EmailAddress('userName', 'user-name@localhost'),
        EmailAddress('userName', 'USER@localhost'), // uppercase local part
        EmailAddress('userName', '"quoted.name"@localhost'),
        EmailAddress('userName', 'a.b-c_d@localhost'),
      ];

      for (final email in validEmails) {
        test('should return true for "${email.emailAddress}"', () {
          expect(AppUtils.isEmailLocalhost(email.emailAddress), isTrue);
        });
      }
    });

    group('Invalid localhost email addresses', () {
      final invalidEmails = [
        // Missing @localhost
        EmailAddress('userName', 'localhost'),
        // Wrong or incomplete domain
        EmailAddress('userName', 'bob@local'),
        EmailAddress('userName', '123@domain'),
        EmailAddress('userName', 'alic.2312e@'),
        // Invalid characters in local part
        EmailAddress('userName', 'a,.2312lic.2312e@'),
        EmailAddress('userName', 'ali ce@localhost'),
        EmailAddress('userName', 'ali,ce@localhost'),
        // Multiple @ symbols
        EmailAddress('userName', 'a@b@localhost'),
        // Domain variants that look similar but invalid
        EmailAddress('userName', 'alice@localhost.com'),
        EmailAddress('userName', 'alice@.localhost'),
        EmailAddress('userName', 'alice@localhost.'),
        // Missing local part
        EmailAddress('userName', '@localhost'),
        // Empty or only spaces
        EmailAddress('userName', ''),
        EmailAddress('userName', '   '),
        // URL-like or extended domain format
        EmailAddress('userName', 'alice@localhost:8080'),
        EmailAddress('userName', 'alice@localhost/path'),
      ];

      for (final email in invalidEmails) {
        test('should return false for "${email.emailAddress}"', () {
          expect(AppUtils.isEmailLocalhost(email.emailAddress), isFalse);
        });
      }
    });

    group('Edge cases & normalization', () {
      test('should trim spaces and still be valid', () {
        expect(AppUtils.isEmailLocalhost('  alice@localhost  '), isTrue);
      });

      test('should be case-sensitive for domain', () {
        expect(AppUtils.isEmailLocalhost('alice@LOCALHOST'), isFalse);
      });

      test('should allow uppercase local part', () {
        expect(AppUtils.isEmailLocalhost('ALICE@localhost'), isTrue);
      });

      test('should reject quoted local part with invalid dots', () {
        expect(AppUtils.isEmailLocalhost('"ab..cd"@localhost'), isTrue);
      });

      test('should reject local part with trailing dot', () {
        expect(AppUtils.isEmailLocalhost('alice.@localhost'), isFalse);
      });

      test('should reject local part starting with dot', () {
        expect(AppUtils.isEmailLocalhost('.alice@localhost'), isFalse);
      });
    });
  });
}
