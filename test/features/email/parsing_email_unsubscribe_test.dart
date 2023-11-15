
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

void main() {
  group('parsing email unsubscribe test', () {
    test('parsingUnsubscribe returns null for empty input', () {
      expect(EmailUtils.parsingUnsubscribe(''), isNull);
    });

    test('parsingUnsubscribe returns null for input without links', () {
      expect(EmailUtils.parsingUnsubscribe('Some text without links'), isNull);
    });

    test('parsingUnsubscribe parses mailto links', () {
      final emailUnsubscribe = EmailUtils.parsingUnsubscribe('<mailto:user@example.com>');
      expect(emailUnsubscribe, isNotNull);
      expect(emailUnsubscribe!.mailtoLinks, contains('mailto:user@example.com'));
      expect(emailUnsubscribe.httpLinks, isEmpty);
    });

    test('parsingUnsubscribe parses http links', () {
      final emailUnsubscribe = EmailUtils.parsingUnsubscribe('<http://example.com>');
      expect(emailUnsubscribe, isNotNull);
      expect(emailUnsubscribe!.httpLinks, contains('http://example.com'));
      expect(emailUnsubscribe.mailtoLinks, isEmpty);
    });

    test('parsingUnsubscribe parses https links', () {
      final emailUnsubscribe = EmailUtils.parsingUnsubscribe('<https://example.com>');
      expect(emailUnsubscribe, isNotNull);
      expect(emailUnsubscribe!.httpLinks, contains('https://example.com'));
      expect(emailUnsubscribe.mailtoLinks, isEmpty);
    });

    test('parsingUnsubscribe parses both http and https links', () {
      final emailUnsubscribe = EmailUtils.parsingUnsubscribe('<http://example.com>, <https://example.com>');
      expect(emailUnsubscribe, isNotNull);
      expect(emailUnsubscribe!.httpLinks, containsAll(['http://example.com', 'https://example.com']));
      expect(emailUnsubscribe.mailtoLinks, isEmpty);
    });

    test('parsingUnsubscribe parses both mailto and http links', () {
      final emailUnsubscribe = EmailUtils.parsingUnsubscribe('<mailto:support@example.com>, <http://example.com>');
      expect(emailUnsubscribe, isNotNull);
      expect(emailUnsubscribe!.mailtoLinks, contains('mailto:support@example.com'));
      expect(emailUnsubscribe.httpLinks, contains('http://example.com'));
    });

    test('parsingUnsubscribe parses both mailto and http links without <>', () {
      final emailUnsubscribe = EmailUtils.parsingUnsubscribe('mailto:support@example.com, http://example.com');
      expect(emailUnsubscribe, isNotNull);
      expect(emailUnsubscribe!.mailtoLinks, contains('mailto:support@example.com'));
      expect(emailUnsubscribe.httpLinks, contains('http://example.com'));
    });

    test('parsingUnsubscribe parses more mailto and http links', () {
      final emailUnsubscribe = EmailUtils.parsingUnsubscribe('<mailto:support@example.com>, <http://example.com>, <http://example2.com>, <http://example3.com>, <mailto:support@example2.com>, <mailto:support@example3.com>');
      expect(emailUnsubscribe, isNotNull);
      expect(emailUnsubscribe!.mailtoLinks, containsAll(['mailto:support@example.com', 'mailto:support@example2.com', 'mailto:support@example3.com']));
      expect(emailUnsubscribe.httpLinks, containsAll(['http://example.com', 'http://example2.com', 'http://example3.com']));
    });

    test('parsingUnsubscribe returns null for input with invalid links', () {
      expect(EmailUtils.parsingUnsubscribe('Invalid link: invalid'), isNull);
    });
  });
}