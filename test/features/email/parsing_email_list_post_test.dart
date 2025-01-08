import 'package:flutter_test/flutter_test.dart';
import 'package:model/extensions/list_email_address_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

void main() {
  group('parsing email list post test', () {
    test('parsingListPost returns null for empty input', () {
      expect(EmailUtils.parsingListPost(''), isNull);
    });

    test('parsingListPost returns null for input without links', () {
      expect(EmailUtils.parsingListPost('Some text without links'), isNull);
    });

    test('parsingListPost parses mailto links', () {
      final listEmailAddress =
          EmailUtils.parsingListPost('<mailto:user@example.com>');
      expect(listEmailAddress, isNotNull);
      expect(listEmailAddress![0].email, contains('user@example.com'));
    });

    test('parsingListPost parses both mailto without <>', () {
      final listEmailAddress =
          EmailUtils.parsingListPost('mailto:support@example.com');
      expect(listEmailAddress, isNotNull);
      expect(listEmailAddress![0].email, contains('support@example.com'));
    });

    test('parsingListPost parses more mailto', () {
      final listEmailAddress = EmailUtils.parsingListPost(
          '<mailto:support@example.com>, <mailto:support@example2.com>, <mailto:support@example3.com>');
      expect(listEmailAddress, isNotNull);
      expect(listEmailAddress!.length, equals(3));
      expect(
        listEmailAddress.asSetAddress(),
        containsAll({
          'support@example.com',
          'support@example2.com',
          'support@example3.com'
        }),
      );
    });

    test('parsingListPost returns null for input with invalid links', () {
      expect(EmailUtils.parsingListPost('Invalid link: invalid'), isNull);
    });
  });
}
