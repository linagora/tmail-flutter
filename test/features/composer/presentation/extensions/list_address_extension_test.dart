import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_address_extension.dart';

void main() {
  group('ListAddressExtension.toFilteredEmailAddressList', () {
    test('removes existing emails and duplicates', () {
      final addresses = [
        'a@example.com',
        'b@example.com',
        'B@EXAMPLE.COM', // duplicate in different case
        'c@example.com',
      ];
      final existingEmails = [
        EmailAddress('B', 'b@example.com'),
        EmailAddress('X', 'x@example.com'),
      ];

      final result = addresses.toFilteredEmailAddressList(existingEmails);

      expect(result.map((e) => e.emailAddress), [
        'a@example.com',
        'c@example.com',
      ]);
    });

    test('keeps all unique and non-existing emails', () {
      final addresses = [
        'a@example.com',
        'b@example.com',
        'c@example.com',
      ];
      final existingEmails = [
        EmailAddress('Someone', 'z@example.com'),
      ];

      final result = addresses.toFilteredEmailAddressList(existingEmails);

      expect(result.map((e) => e.emailAddress), [
        'a@example.com',
        'b@example.com',
        'c@example.com',
      ]);
    });

    test('skips invalid emails', () {
      final addresses = [
        'invalid-email',
        'valid@example.com',
      ];
      final existingEmails = <EmailAddress>[];

      final result = addresses.toFilteredEmailAddressList(existingEmails);

      expect(result.length, 2);
      expect(result[0].emailAddress, 'invalid-email');
      expect(result[0].name, isNull);
      expect(result[1].emailAddress, 'valid@example.com');
    });

    test('removes duplicates within the list', () {
      final addresses = [
        'a@example.com',
        'A@EXAMPLE.COM', // duplicate in different case
        'b@example.com',
        'b@example.com',
      ];
      final existingEmails = <EmailAddress>[];

      final result = addresses.toFilteredEmailAddressList(existingEmails);

      expect(result.map((e) => e.emailAddress), [
        'a@example.com',
        'b@example.com',
      ]);
    });

    test('removes addresses matching normalized existingEmails', () {
      final addresses = [
        '  A@Example.Com  ',
        'b@example.com',
      ];
      final existingEmails = [
        EmailAddress('A', 'a@example.com'),
      ];

      final result = addresses.toFilteredEmailAddressList(existingEmails);

      expect(result.map((e) => e.emailAddress), ['b@example.com']);
    });
  });
}
