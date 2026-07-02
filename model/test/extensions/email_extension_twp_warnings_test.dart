import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:model/email/twp_warning.dart';
import 'package:model/extensions/email_extension.dart';

void main() {
  final twpKey = IndividualHeaderIdentifier.asText(twpMessageHeaderName).all();

  group('EmailExtension.twpWarnings:', () {
    test('returns empty list when individualHeaders has no TWP entry', () {
      final email = Email();

      expect(email.twpWarnings, isEmpty);
    });

    test('parses and deduplicates AllHeaderValue built directly (no JSON round-trip)', () {
      final email = Email(individualHeaders: {
        twpKey: const AllHeaderValue([
          TextHeaderValue('level:info code:suspicious-sender external sender'),
          TextHeaderValue('level:warn code:virus-detected virus found'),
          TextHeaderValue('level:info code:suspicious-sender external sender'),
        ]),
      });

      final warnings = email.twpWarnings;

      expect(warnings.length, 2);
      expect(warnings[0].code, 'suspicious-sender');
      expect(warnings[0].level, TwpWarningLevel.info);
      expect(warnings[1].code, 'virus-detected');
      expect(warnings[1].level, TwpWarningLevel.warn);
      expect(warnings[1].index, 1);
    });

    test('parses AllHeaderValue reconstructed through Email.fromJson (first use of .all() in codebase)', () {
      final json = {
        'id': 'email1',
        'header:$twpMessageHeaderName:asText:all': [
          'level:info code:suspicious-sender This email is from an external sender.',
          'level:error code:virus-detected Malware found in attachment.',
        ],
      };

      final email = Email.fromJson(json);
      final headerValue = email.individualHeaders[twpKey];

      expect(headerValue, isA<AllHeaderValue>());
      expect((headerValue as AllHeaderValue).values, everyElement(isA<TextHeaderValue>()));

      final warnings = email.twpWarnings;
      expect(warnings.length, 2);
      expect(warnings[0].code, 'suspicious-sender');
      expect(warnings[0].level, TwpWarningLevel.info);
      expect(warnings[1].code, 'virus-detected');
      expect(warnings[1].level, TwpWarningLevel.error);
    });

    test('ignores null/blank entries in AllHeaderValue', () {
      final email = Email(individualHeaders: {
        twpKey: const AllHeaderValue([
          TextHeaderValue(null),
          TextHeaderValue('   '),
          TextHeaderValue('level:info code:a text'),
        ]),
      });

      expect(email.twpWarnings.length, 1);
    });
  });

  group('EmailExtension.twpMessagesRaw:', () {
    test('returns null when no TWP header present', () {
      expect(Email().twpMessagesRaw, isNull);
    });

    test('returns raw ordered text values, unparsed, undeduplicated', () {
      final email = Email(individualHeaders: {
        twpKey: const AllHeaderValue([
          TextHeaderValue('level:info code:a first'),
          TextHeaderValue('level:info code:a first'),
        ]),
      });

      expect(email.twpMessagesRaw, [
        'level:info code:a first',
        'level:info code:a first',
      ]);
    });
  });
}
