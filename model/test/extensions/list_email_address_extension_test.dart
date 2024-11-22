import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/extensions/list_email_address_extension.dart';

void main() {
  group('ListEmailAddressExtension::toEscapeHtmlString::', () {
    test('Should returns empty string for null or empty list', () {
      expect((<EmailAddress>{}).toEscapeHtmlString(', '), '');

      Set<EmailAddress>? listEmails;
      expect(listEmails.toEscapeHtmlString(', '), '');
    });

    test('Should returns joined HTML strings with separator', () {
      final emails = {
        EmailAddress('John Doe', 'john@example.com'),
        EmailAddress('Jane Smith', 'jane@example.com'),
      };
      final result = emails.toEscapeHtmlString(' | ');

      expect(result, 'John Doe &lt;john@example.com&gt; | Jane Smith &lt;jane@example.com&gt;');
    });

    test('Should handles displayName-only or email-only cases', () {
      final emails = {
        EmailAddress('John Doe', ''),
        EmailAddress('', 'jane@example.com'),
      };
      final result = emails.toEscapeHtmlString(', ');

      expect(result, 'John Doe, &lt;jane@example.com&gt;');
    });
  });

  group('ListEmailAddressExtension::toEscapeHtmlStringUseCommaSeparator::', () {
    test('Should uses ", " as separator', () {
      final emails = {
        EmailAddress('John Doe', 'john@example.com'),
        EmailAddress('Jane Smith', 'jane@example.com'),
      };
      final result = emails.toEscapeHtmlStringUseCommaSeparator();

      expect(result, 'John Doe &lt;john@example.com&gt;, Jane Smith &lt;jane@example.com&gt;');
    });
  });

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
