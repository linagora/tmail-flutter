import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

void main() {
  group('EmailUtils::isValidEmail', () {
    group('Valid public domain emails', () {
      final validEmails = [
        'alice@example.com',
        'bob.smith@linagora.com',
        'user_name@sub.domain.org',
        'user-name@domain.io',
        'user+folder@gmail.com',
        '"quoted.name"@example.com',
        'first.last@123domain.net',
      ];

      for (final email in validEmails) {
        test('should return true for "$email"', () {
          expect(EmailUtils.isValidEmail(email), isTrue);
        });
      }
    });

    group('Valid localhost emails', () {
      final localhostEmails = [
        'root@localhost',
        'admin@localhost',
        'test_user@localhost',
        'a.b.c@localhost',
      ];

      for (final email in localhostEmails) {
        test('should return true for "$email"', () {
          expect(EmailUtils.isValidEmail(email), isTrue);
        });
      }
    });

    group('Invalid emails', () {
      final invalidEmails = [
        '', // empty
        '   ', // whitespace
        'plainaddress', // no @
        '@domain.com', // missing local-part
        'user@', // missing domain
        'user@.', // invalid domain
        'user@domain..com', // double dot
        'user@@domain.com', // double @
        '.user@domain.com', // starts with dot
        'user.@domain.com', // ends with dot
        'user..name@domain.com', // double dot local
        'user@-domain.com', // domain starts with dash
        'user@domain-.com', // domain ends with dash
        'user@domain,com', // invalid character
        'user domain@example.com', // space inside
        'user@domain@domain.com', // multiple @
        'user@localhost.', // trailing dot
        'user@localhost:8080', // port
        'user@localhost/path', // path
      ];

      for (final email in invalidEmails) {
        test('should return false for "$email"', () {
          expect(EmailUtils.isValidEmail(email), isFalse);
        });
      }
    });

    group('⚙️ Edge cases & error catching', () {
      test('should return false for malformed quoted string', () {
        expect(EmailUtils.isValidEmail('"ab..cd"@example.com'), isFalse);
      });

      test('should return false for domain with brackets but invalid IP', () {
        expect(EmailUtils.isValidEmail('user@[999.999.999.999]'), isFalse);
      });

      test('should return false for missing domain after @', () {
        expect(EmailUtils.isValidEmail('user@'), isFalse);
      });

      test('should return false for special chars in local part', () {
        expect(EmailUtils.isValidEmail('user()@domain.com'), isFalse);
      });

      test('should trim spaces before validating', () {
        expect(EmailUtils.isValidEmail('  alice@example.com  '), isTrue);
      });
    });
  });
}
