import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header.dart';
import 'package:model/email/email_property.dart';
import 'package:model/email/twp_warning/twp_warning_level.dart';
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

  group('ListEmailHeaderExtension::twpWarnings', () {
    test('returns empty list when no `X-TWP-Message` header is present', () {
      final emailHeaders = {EmailHeader('OtherHeader', 'Value')};
      expect(emailHeaders.twpWarnings, isEmpty);
    });

    test('returns empty list for null set', () {
      Set<EmailHeader>? emailHeaders;
      expect(emailHeaders.twpWarnings, isEmpty);
    });

    test('parses a single warning with level, code and fallback text', () {
      final emailHeaders = {
        EmailHeader(
          EmailProperty.headerTwpMessageKey,
          'level:info code:suspicious-sender This email is from an external sender.',
        )
      };

      final warnings = emailHeaders.twpWarnings;
      expect(warnings.length, 1);
      expect(warnings.first.level, TwpWarningLevel.info);
      expect(warnings.first.code, 'suspicious-sender');
      expect(warnings.first.fallbackText, 'This email is from an external sender.');
      expect(warnings.first.index, 0);
    });

    test('parses several warnings and assigns positional indexes', () {
      final emailHeaders = {
        EmailHeader(EmailProperty.headerTwpMessageKey, 'level:warn code:virus Virus found'),
        EmailHeader(EmailProperty.headerTwpMessageKey, 'level:error code:virus-removed Virus removed'),
      };

      final warnings = emailHeaders.twpWarnings;
      expect(warnings.length, 2);
      expect(warnings[0].index, 0);
      expect(warnings[0].level, TwpWarningLevel.warn);
      expect(warnings[1].index, 1);
      expect(warnings[1].level, TwpWarningLevel.error);
      expect(warnings[1].code, 'virus-removed');
    });

    test('defaults to info level and null code when tokens are missing', () {
      final emailHeaders = {
        EmailHeader(EmailProperty.headerTwpMessageKey, 'A plain warning message')
      };

      final warning = emailHeaders.twpWarnings.single;
      expect(warning.level, TwpWarningLevel.info);
      expect(warning.code, isNull);
      expect(warning.fallbackText, 'A plain warning message');
    });

    test('defaults to info level when the level value is unknown', () {
      final emailHeaders = {
        EmailHeader(EmailProperty.headerTwpMessageKey, 'level:unknown code:virus Text')
      };

      final warning = emailHeaders.twpWarnings.single;
      expect(warning.level, TwpWarningLevel.info);
      expect(warning.code, 'virus');
    });
  });
}
