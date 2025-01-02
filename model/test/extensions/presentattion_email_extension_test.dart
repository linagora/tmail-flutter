import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/presentation_email_extension.dart';
import 'package:model/email/presentation_email.dart';

void main() {
  group('PresentationEmailExtension::getCountMailAddressWithoutMe::', () {
    test('Should return the correct count of email addresses excluding the user', () {
      // Arrange
      final email = PresentationEmail(
        to: {EmailAddress('Alice', 'alice@example.com')},
        cc: {EmailAddress('Bob', 'bob@example.com')},
        bcc: {EmailAddress('Charlie', 'charlie@example.com')},
        from: {EmailAddress('User', 'user@example.com')},
      );

      // Act
      final count = email.getCountMailAddressWithoutMe('user@example.com');

      // Assert
      expect(count, 3);
    });

    test('Should return 0 when all email addresses are the user', () {
      // Arrange
      final email = PresentationEmail(
        to: {EmailAddress('User', 'user@example.com')},
        cc: {EmailAddress('User', 'user@example.com')},
        bcc: {EmailAddress('User', 'user@example.com')},
        from: {EmailAddress('User', 'user@example.com')},
      );

      // Act
      final count = email.getCountMailAddressWithoutMe('user@example.com');

      // Assert
      expect(count, 0);
    });

    test('Should return the correct count excluding multiple instances of the user', () {
      // Arrange
      final email = PresentationEmail(
        to: {
          EmailAddress('Alice', 'alice@example.com'),
          EmailAddress('User', 'user@example.com')
        },
        cc: {
          EmailAddress('User', 'user@example.com')
        },
        bcc: {
          EmailAddress('Charlie', 'charlie@example.com')
        },
        from: {
          EmailAddress('User', 'user@example.com')
        },
      );

      // Act
      final count = email.getCountMailAddressWithoutMe('user@example.com');

      // Assert
      expect(count, 2);
    });
  });
}
