import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

void main() {
  group('EmailUtils::extractMailtoLinksFromListPost::', () {
    test('should return a list of mailto links when valid mailto links are present', () {
      const listPost = '<mailto:example1@test.com>, <mailto:example2@test.com>';
      final result = EmailUtils.extractMailtoLinksFromListPost(listPost);

      expect(result, ['mailto:example1@test.com', 'mailto:example2@test.com']);
    });

    test('should return an empty list when no mailto links are present', () {
      const listPost = '<example@test.com>, <other@test.com>';
      final result = EmailUtils.extractMailtoLinksFromListPost(listPost);

      expect(result, isEmpty);
    });

    test('should return an empty list for an empty string input', () {
      const listPost = '';
      final result = EmailUtils.extractMailtoLinksFromListPost(listPost);

      expect(result, isEmpty);
    });

    test('should handle inputs with whitespace only', () {
      const listPost = '   ';
      final result = EmailUtils.extractMailtoLinksFromListPost(listPost);

      expect(result, isEmpty);
    });

    test('should handle unexpected exceptions and return an empty list', () {
      const listPost = '\uD800';
      final result = EmailUtils.extractMailtoLinksFromListPost(listPost);

      expect(result, isEmpty);
    });

    test('should decode encoded URI input and extract mailto links', () {
      const listPost = '<mailto:example1%40test.com>, <mailto:example2%40test.com>';
      final result = EmailUtils.extractMailtoLinksFromListPost(listPost);

      expect(result, ['mailto:example1@test.com', 'mailto:example2@test.com']);
    });

    test('should handle mailto links with additional parameters like cc and bcc', () {
      const listPost = '<mailto:johndoe@fakeemail.com>, <mailto:janedoe@fakeemail.com?cc=jackdoe@fakeemail.com&bcc=jennydoe@fakeemail.com>';
      final result = EmailUtils.extractMailtoLinksFromListPost(listPost);

      expect(result, ['mailto:johndoe@fakeemail.com', 'mailto:janedoe@fakeemail.com?cc=jackdoe@fakeemail.com&bcc=jennydoe@fakeemail.com']);
    });

    test('should handle mailto links with additional parameters like cc, bcc, subject and body', () {
      const listPost = '<mailto:johndoe@fakeemail.com>, <mailto:janedoe@fakeemail.com?cc=jackdoe@fakeemail.com&bcc=jennydoe@fakeemail.com&subject=TestSubject&body=TestBody>';
      final result = EmailUtils.extractMailtoLinksFromListPost(listPost);

      expect(result, [
        'mailto:johndoe@fakeemail.com',
        'mailto:janedoe@fakeemail.com?cc=jackdoe@fakeemail.com&bcc=jennydoe@fakeemail.com&subject=TestSubject&body=TestBody',
      ]);
    });
  });

  group('EmailUtils::extractRecipientsFromMailtoLink::', () {
    test('should return empty lists for empty mailtoLink', () {
      final result = EmailUtils.extractRecipientsFromMailtoLink('');
      expect(result.toMailAddresses, isEmpty);
      expect(result.ccMailAddresses, isEmpty);
      expect(result.bccMailAddresses, isEmpty);
    });

    test('should extract recipients from valid mailtoLink', () {
      const mailtoLink = 'mailto:test@example.com?cc=cc@example.com&bcc=bcc@example.com';

      final result = EmailUtils.extractRecipientsFromMailtoLink(mailtoLink);

      expect(result.toMailAddresses, [EmailAddress(null, 'test@example.com')]);
      expect(result.ccMailAddresses, [EmailAddress(null, 'cc@example.com')]);
      expect(result.bccMailAddresses, [EmailAddress(null, 'bcc@example.com')]);
    });

    test('should handle malformed mailtoLink gracefully', () {
      const malformedMailtoLink = 'mailto:test@example.com?invalid=params';

      final result = EmailUtils.extractRecipientsFromMailtoLink(malformedMailtoLink);

      expect(result.toMailAddresses, [EmailAddress(null, 'test@example.com')]);
      expect(result.ccMailAddresses, isEmpty);
      expect(result.bccMailAddresses, isEmpty);
    });

    test('should handle exceptions gracefully', () {
      const invalidMailtoLink = 'mailto:invalid-link, mailto:%E0%A4%A';

      final result = EmailUtils.extractRecipientsFromMailtoLink(invalidMailtoLink);

      expect(result.toMailAddresses, isEmpty);
      expect(result.ccMailAddresses, isEmpty);
      expect(result.bccMailAddresses, isEmpty);
    });

    test('should decode and extract recipients from encoded mailtoLink', () {
      const encodedMailtoLink = 'mailto:test%40example.com?cc=cc1%40example.com%2Ccc2%40example.com&bcc=bcc%40example.com';

      final result = EmailUtils.extractRecipientsFromMailtoLink(encodedMailtoLink);

      expect(result.toMailAddresses, [EmailAddress(null, 'test@example.com')]);
      expect(result.ccMailAddresses, [EmailAddress(null, 'cc1@example.com'), EmailAddress(null, 'cc2@example.com')]);
      expect(result.bccMailAddresses, [EmailAddress(null, 'bcc@example.com')]);
    });

    test('should extract recipients from mailto links with additional parameters like cc, bcc, subject and body', () {
      const mailtoLink = 'mailto:test@example.com?cc=cc@example.com&bcc=bcc@example.com&subject=TestSubject&body=TestBody';

      final result = EmailUtils.extractRecipientsFromMailtoLink(mailtoLink);

      expect(result.toMailAddresses, [EmailAddress(null, 'test@example.com')]);
      expect(result.ccMailAddresses, [EmailAddress(null, 'cc@example.com')]);
      expect(result.bccMailAddresses, [EmailAddress(null, 'bcc@example.com')]);
    });
  });

  group('EmailUtils::extractRecipientsFromListPost::', () {
    test('should return empty lists for empty listPost', () {
      final result = EmailUtils.extractRecipientsFromListPost('');

      expect(result.toMailAddresses, isEmpty);
      expect(result.ccMailAddresses, isEmpty);
      expect(result.bccMailAddresses, isEmpty);
    });

    test('should extract recipients from a valid listPost', () {
      const listPost = '<mailto:test@example.com?cc=cc@example.com&bcc=bcc@example.com>, <mailto:another@example.com>';

      final result = EmailUtils.extractRecipientsFromListPost(listPost);

      expect(result.toMailAddresses, [
        EmailAddress(null, 'test@example.com'),
        EmailAddress(null, 'another@example.com'),
      ]);
      expect(result.ccMailAddresses, [EmailAddress(null, 'cc@example.com')]);
      expect(result.bccMailAddresses, [EmailAddress(null, 'bcc@example.com')]);
    });

    test('should handle listPost with no valid mailto links', () {
      const listPost = 'content without mailto links';

      final result = EmailUtils.extractRecipientsFromListPost(listPost);

      expect(result.toMailAddresses, isEmpty);
      expect(result.ccMailAddresses, isEmpty);
      expect(result.bccMailAddresses, isEmpty);
    });

    test('should decode and extract recipients from listPost with encoded mailto links', () {
      const listPost = '%3Cmailto%3Atest%2540example.com%3Fcc%3Dcc1%2540example.com%252Ccc2%2540example.com%26bcc%3Dbcc%2540example.com%3E%2C%20%3Cmailto%3Aanother%2540example.com%3E';

      final result = EmailUtils.extractRecipientsFromListPost(listPost);

      expect(result.toMailAddresses, [
        EmailAddress(null, 'test@example.com'),
        EmailAddress(null, 'another@example.com'),
      ]);
      expect(result.ccMailAddresses, [
        EmailAddress(null, 'cc1@example.com'),
        EmailAddress(null, 'cc2@example.com'),
      ]);
      expect(result.bccMailAddresses, [
        EmailAddress(null, 'bcc@example.com'),
      ]);
    });

    test('should extract recipients from list post  with additional parameters like cc, bcc, subject and body', () {
      const listPost = '<mailto:test@example.com?cc=cc@example.com&bcc=bcc@example.com&subject=TestSubject&body=TestBody>';

      final result = EmailUtils.extractRecipientsFromListPost(listPost);

      expect(result.toMailAddresses, [EmailAddress(null, 'test@example.com')]);
      expect(result.ccMailAddresses, [EmailAddress(null, 'cc@example.com')]);
      expect(result.bccMailAddresses, [EmailAddress(null, 'bcc@example.com')]);
    });
  });
}
