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
