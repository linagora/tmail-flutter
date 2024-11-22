import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/list_email_address_extension.dart';

void main() {
  group('ListEmailAddressExtension::removeInvalidEmails::test', () {
    test('SHOULD remove email addresses that are empty', () {
      final emails = [
        EmailAddress('Alice', 'alice@example.com'),
        EmailAddress('Bob', ''),
        EmailAddress('Charlie', 'charlie@example.com'),
      ];

      final validEmails = emails.removeInvalidEmails('bob@example.com');

      expect(validEmails.length, 2);
      expect(validEmails[0].emailAddress, 'alice@example.com');
      expect(validEmails[1].emailAddress, 'charlie@example.com');
    });

    test('SHOULD remove email addresses that match the provided username', () {
      final emails = [
        EmailAddress('Alice', 'alice@example.com'),
        EmailAddress('Bob', 'bob@example.com'),
        EmailAddress('Charlie', 'charlie@example.com'),
      ];

      final validEmails = emails.removeInvalidEmails('bob@example.com');

      expect(validEmails.length, 2);
      expect(validEmails[0].emailAddress, 'alice@example.com');
      expect(validEmails[1].emailAddress, 'charlie@example.com');
    });

    test('SHOULD remove duplicate email addresses, keeping only the first occurrence', () {
      final emails = [
        EmailAddress('Alice', 'alice@example.com'),
        EmailAddress('Bob', 'bob@example.com'),
        EmailAddress('Charlie', 'alice@example.com'),
        EmailAddress('David', 'david@example.com'),
      ];

      final validEmails = emails.removeInvalidEmails('bob@example.com');

      expect(validEmails.length, 2);
      expect(validEmails[0].emailAddress, 'alice@example.com');
      expect(validEmails[1].emailAddress, 'david@example.com');
    });

    test('SHOULD return an empty list if all email addresses are invalid', () {
      final emails = [
        EmailAddress('Alice', ''),
        EmailAddress('Bob', 'bob@example.com'),
        EmailAddress('Charlie', 'bob@example.com'),
      ];

      final validEmails = emails.removeInvalidEmails('bob@example.com');

      expect(validEmails.isEmpty, true);
    });

    test('SHOULD return an empty list for an empty input list', () {
      final emails = <EmailAddress>[];

      final validEmails = emails.removeInvalidEmails('bob@example.com');

      expect(validEmails.isEmpty, true);
    });
  });
}
