import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';

void main() {
  group('EmailAddressExtension::asFullStringWithLtGtCharacter::', () {
    test('Should returns displayName and emailAddress formatted correctly', () {
      final emailAddress = EmailAddress(
        'John Doe',
        'john.doe@example.com',
      );
      expect(
        emailAddress.asFullStringWithLtGtCharacter(),
        'John Doe <john.doe@example.com>',
      );
    });

    test('Should returns displayName as is when emailAddress is empty', () {
      final emailAddress = EmailAddress(
        'Jane Doe',
        '',
      );
      expect(emailAddress.asFullStringWithLtGtCharacter(), 'Jane Doe');
    });

    test('Should not re-case displayName', () {
      final emailAddress = EmailAddress(
        'Test BTELLIER',
        'btellier@example.com',
      );
      expect(
        emailAddress.asFullStringWithLtGtCharacter(),
        'Test BTELLIER <btellier@example.com>',
      );
    });

    test('Should returns emailAddress enclosed in <> when displayName is empty', () {
      final emailAddress = EmailAddress(
        '',
        'jane.doe@example.com',
      );
      expect(emailAddress.asFullStringWithLtGtCharacter(), '<jane.doe@example.com>');
    });

    test('Should returns an empty string when both displayName and emailAddress are empty', () {
      final emailAddress = EmailAddress('', '');
      expect(emailAddress.asFullStringWithLtGtCharacter(), '');
    });
  });
}