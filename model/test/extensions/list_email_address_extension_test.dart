import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
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
}
