import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:model/email/email_property.dart';
import 'package:model/extensions/list_email_header_extension.dart';

void main() {
  group('ListEmailHeaderExtension::test', () {
    test('sMimeStatus returns correct value when header `X-SMIME-Status` is present', () {
      final emailHeaders = {
        EmailHeader(EmailProperty.headerSMimeStatusKey, 'Good signature')
      };
      expect(emailHeaders.sMimeStatus, 'Good signature');
    });

    test('sMimeStatus returns empty string when header is absent', () {
      final emailHeaders = {
        EmailHeader('OtherHeader', 'Value')
      };
      expect(emailHeaders.sMimeStatus, '');
    });

    test('sMimeStatus returns empty string for null set', () {
      Set<EmailHeader>? emailHeaders;
      expect(emailHeaders.sMimeStatus, '');
    });

    test('sMimeStatus trims start whitespace from the value', () {
      final emailHeaders = {
        EmailHeader(EmailProperty.headerSMimeStatusKey, ' Good signature')
      };
      expect(emailHeaders.sMimeStatus, 'Good signature');
    });

    test('sMimeStatus trims end whitespace from the value', () {
      final emailHeaders = {
        EmailHeader(EmailProperty.headerSMimeStatusKey, 'Good signature ')
      };
      expect(emailHeaders.sMimeStatus, 'Good signature');
    });

    test('sMimeStatus trims start-end whitespace from the value', () {
      final emailHeaders = {
        EmailHeader(EmailProperty.headerSMimeStatusKey, ' Good signature ')
      };
      expect(emailHeaders.sMimeStatus, 'Good signature');
    });
  });
}
