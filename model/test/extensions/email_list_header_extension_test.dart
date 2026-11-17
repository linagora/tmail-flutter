import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/email_list_header_extension.dart';
import 'package:model/extensions/presentation_email_extension.dart';

void main() {
  const unsubscribeRaw =
      ' <mailto:unsub@list.example.com?subject=unsubscribe>,\r\n <https://list.example.com/u?id=1>';

  Email rawEmail() => Email.fromJson({
        'id': 'e1',
        'header:List-Unsubscribe': unsubscribeRaw,
        'header:List-Post': ' <mailto:list@example.com>',
      });

  Map<IndividualHeaderIdentifier, EmailHeaderValue> mergeOverLegacy({
    required IndividualHeaderIdentifier legacyHeader,
    required Email incoming,
    required String updatedProperty,
  }) {
    final base = Email(
      id: EmailId(Id('e1')),
      individualHeaders: {legacyHeader: const TextHeaderValue('<mailto:old@x.y>')},
    );
    return base.mergeTrackedIndividualHeaders(incoming, Properties({updatedProperty}));
  }

  group('EmailListHeaderExtension', () {
    test('toPresentationEmail().listUnsubscribe reads the raw header', () {
      final presentation = rawEmail().toPresentationEmail();
      expect(presentation.listUnsubscribe, contains('mailto:unsub@list.example.com'));
    });

    test('Email.listUnsubscribe reads the raw header', () {
      expect(rawEmail().listUnsubscribe, contains('https://list.example.com/u?id=1'));
    });

    test('listPost reads the raw header', () {
      expect(rawEmail().listPost, '<mailto:list@example.com>');
    });

    test('mergeTrackedIndividualHeaders keeps the raw List-Unsubscribe from Email/changes', () {
      final base = Email(id: EmailId(Id('e1')));
      final merged = base.mergeTrackedIndividualHeaders(
        rawEmail(),
        Properties({ListHeaderIdentifier.listUnsubscribe.value}),
      );
      final value = merged[ListHeaderIdentifier.listUnsubscribe];
      expect(value, isA<RawHeaderValue>());
      expect((value as RawHeaderValue).value, contains('mailto:unsub@list.example.com'));
    });

    for (final (name, legacyHeader, rawHeader, read) in [
      (
        'List-Unsubscribe',
        IndividualHeaderIdentifier.listUnsubscribeHeader,
        ListHeaderIdentifier.listUnsubscribe,
        (Email email) => email.listUnsubscribe,
      ),
      (
        'List-Post',
        IndividualHeaderIdentifier.listPostHeader,
        ListHeaderIdentifier.listPost,
        (Email email) => email.listPost,
      ),
    ]) {
      test('clearing raw $name also drops legacy asText', () {
        final merged = mergeOverLegacy(
          legacyHeader: legacyHeader,
          incoming: Email(id: EmailId(Id('e1'))),
          updatedProperty: rawHeader.value,
        );
        expect(read(Email(id: EmailId(Id('e1')), individualHeaders: merged)), '');
        expect(merged.containsKey(legacyHeader), isFalse);
      });
    }

    test('updating raw List-Unsubscribe drops legacy asText', () {
      final merged = mergeOverLegacy(
        legacyHeader: IndividualHeaderIdentifier.listUnsubscribeHeader,
        incoming: rawEmail(),
        updatedProperty: ListHeaderIdentifier.listUnsubscribe.value,
      );
      expect(merged.containsKey(IndividualHeaderIdentifier.listUnsubscribeHeader), isFalse);
      expect(merged[ListHeaderIdentifier.listUnsubscribe], isA<RawHeaderValue>());
    });

    test('legacy asText is kept when raw List-* is not updated', () {
      final merged = mergeOverLegacy(
        legacyHeader: IndividualHeaderIdentifier.listUnsubscribeHeader,
        incoming: Email(id: EmailId(Id('e1'))),
        updatedProperty: 'subject',
      );
      expect(merged.containsKey(IndividualHeaderIdentifier.listUnsubscribeHeader), isTrue);
    });

    test('PresentationEmail.toEmail round trip keeps List-Unsubscribe', () {
      final email = rawEmail().toPresentationEmail().toEmail();
      expect(email.listUnsubscribe, contains('mailto:unsub@list.example.com'));
    });

    test('absent header gives empty values', () {
      final email = Email.fromJson({'id': 'e2', 'header:List-Unsubscribe': null});
      expect(email.listUnsubscribe, '');
      expect(email.listPost, '');
    });

    test('legacy asText List-* from old cache is still read', () {
      final email = Email(
        id: EmailId(Id('e3')),
        individualHeaders: {
          IndividualHeaderIdentifier.listUnsubscribeHeader:
              const TextHeaderValue('<mailto:old@x.y>'),
          IndividualHeaderIdentifier.listPostHeader:
              const TextHeaderValue('<mailto:old-list@x.y>'),
        },
      );
      expect(email.listUnsubscribe, '<mailto:old@x.y>');
      expect(email.listPost, '<mailto:old-list@x.y>');
      final presentation = email.toPresentationEmail();
      expect(presentation.listUnsubscribe, '<mailto:old@x.y>');
      expect(presentation.listPost, '<mailto:old-list@x.y>');
    });

    test('raw List-Unsubscribe is trimmed and whitespace-only is not a header', () {
      expect(rawEmail().listUnsubscribe.startsWith('<mailto:'), isTrue);
      final blank = Email.fromJson({'id': 'e6', 'header:List-Unsubscribe': ' \r\n '});
      expect(blank.listUnsubscribe, '');
      expect(blank.hasListUnsubscribe, isFalse);
    });

    test('raw List-Unsubscribe is preferred over legacy asText', () {
      final email = Email(
        id: EmailId(Id('e5')),
        individualHeaders: {
          IndividualHeaderIdentifier.listUnsubscribeHeader:
              const TextHeaderValue('<mailto:old@x.y>'),
          ListHeaderIdentifier.listUnsubscribe:
              const RawHeaderValue('<mailto:new@x.y>'),
        },
      );
      expect(email.listUnsubscribe, '<mailto:new@x.y>');
      expect(email.toPresentationEmail().listUnsubscribe, '<mailto:new@x.y>');
    });
  });
}
