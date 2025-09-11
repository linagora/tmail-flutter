import 'package:core/utils/mail/named_address.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/list_named_address_extension.dart';

void main() {
  group('ListNamedAddressExtension.toFilteredEmailAddressList', () {
    test('filters out emails already in existingEmails list', () {
      final namedList = [
        NamedAddress(name: 'A', address: 'a@example.com'),
        NamedAddress(name: 'B', address: 'b@example.com'),
        NamedAddress(name: 'C', address: 'c@example.com'),
      ];

      final existingEmails = [
        EmailAddress('B', 'b@example.com'),
      ];

      final result = namedList.toFilteredEmailAddressList(existingEmails);

      expect(
        result.map((e) => e.emailAddress),
        containsAll(['a@example.com', 'c@example.com']),
      );
      expect(
        result.map((e) => e.emailAddress),
        isNot(contains('b@example.com')),
      );
    });

    test('removes duplicate emails within the same list', () {
      final namedList = [
        NamedAddress(name: 'A1', address: 'a@example.com'),
        NamedAddress(name: 'A2', address: 'A@Example.com'),
        // Duplicate with different case
        NamedAddress(name: 'B', address: 'b@example.com'),
      ];

      final result = namedList.toFilteredEmailAddressList([]);

      expect(result.length, 2);
      expect(
        result.map((e) => e.emailAddress),
        containsAll(['a@example.com', 'b@example.com']),
      );
    });

    test('returns empty list if all emails are either existing or duplicates',
        () {
      final namedList = [
        NamedAddress(name: 'A', address: 'a@example.com'),
        NamedAddress(name: 'A2', address: 'A@Example.com'),
      ];

      final existingEmails = [
        EmailAddress('Existing A', 'a@example.com'),
      ];

      final result = namedList.toFilteredEmailAddressList(existingEmails);

      expect(result, isEmpty);
    });

    test('handles emails with empty name fields', () {
      final namedList = [
        NamedAddress(name: '', address: 'test@example.com'),
      ];

      final result = namedList.toFilteredEmailAddressList([]);

      expect(result.length, 1);
      expect(result.first.emailAddress, 'test@example.com');
    });
  });
}
