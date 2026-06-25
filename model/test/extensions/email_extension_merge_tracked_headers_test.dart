import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_header_value.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:model/extensions/email_extension.dart';

void main() {
  Email makeEmail(Map<IndividualHeaderIdentifier, EmailHeaderValue> headers) {
    return Email(
      id: EmailId(Id('test')),
      individualHeaders: headers,
    );
  }

  String? textValue(EmailHeaderValue? v) => (v as TextHeaderValue?)?.value;

  group('EmailExtension::mergeTrackedIndividualHeaders:', () {
    test('retains existing header when property is not in updatedProperties', () {
      final base = makeEmail({
        IndividualHeaderIdentifier.xPriorityHeader: const TextHeaderValue('1'),
      });
      final newEmail = makeEmail({
        IndividualHeaderIdentifier.xPriorityHeader: const TextHeaderValue('5'),
      });

      final result = base.mergeTrackedIndividualHeaders(
        newEmail,
        Properties({'subject'}),
      );

      expect(textValue(result[IndividualHeaderIdentifier.xPriorityHeader]), '1');
    });

    test('updates header when property is in updatedProperties and newEmail has it', () {
      final base = makeEmail({
        IndividualHeaderIdentifier.xPriorityHeader: const TextHeaderValue('1'),
      });
      final newEmail = makeEmail({
        IndividualHeaderIdentifier.xPriorityHeader: const TextHeaderValue('5'),
      });

      final result = base.mergeTrackedIndividualHeaders(
        newEmail,
        Properties({IndividualHeaderIdentifier.xPriorityHeader.value}),
      );

      expect(textValue(result[IndividualHeaderIdentifier.xPriorityHeader]), '5');
    });

    test('removes header when property is updated but newEmail does not have it', () {
      final base = makeEmail({
        IndividualHeaderIdentifier.xPriorityHeader: const TextHeaderValue('1'),
      });
      final newEmail = makeEmail({});

      final result = base.mergeTrackedIndividualHeaders(
        newEmail,
        Properties({IndividualHeaderIdentifier.xPriorityHeader.value}),
      );

      expect(result.containsKey(IndividualHeaderIdentifier.xPriorityHeader), isFalse);
    });

    test('adds header when base lacks it but newEmail has it and property is updated', () {
      final base = makeEmail({});
      final newEmail = makeEmail({
        IndividualHeaderIdentifier.importanceHeader: const TextHeaderValue('high'),
      });

      final result = base.mergeTrackedIndividualHeaders(
        newEmail,
        Properties({IndividualHeaderIdentifier.importanceHeader.value}),
      );

      expect(textValue(result[IndividualHeaderIdentifier.importanceHeader]), 'high');
    });

    test('handles all six tracked headers independently', () {
      final base = makeEmail({
        IndividualHeaderIdentifier.headerCalendarEvent: const TextHeaderValue('old-cal'),
        IndividualHeaderIdentifier.xPriorityHeader: const TextHeaderValue('old-x'),
        IndividualHeaderIdentifier.importanceHeader: const TextHeaderValue('old-imp'),
        IndividualHeaderIdentifier.priorityHeader: const TextHeaderValue('old-pri'),
        IndividualHeaderIdentifier.listPostHeader: const TextHeaderValue('old-post'),
        IndividualHeaderIdentifier.listUnsubscribeHeader: const TextHeaderValue('old-unsub'),
      });
      final newEmail = makeEmail({
        IndividualHeaderIdentifier.headerCalendarEvent: const TextHeaderValue('new-cal'),
        IndividualHeaderIdentifier.xPriorityHeader: const TextHeaderValue('new-x'),
        IndividualHeaderIdentifier.importanceHeader: const TextHeaderValue('new-imp'),
        IndividualHeaderIdentifier.priorityHeader: const TextHeaderValue('new-pri'),
        IndividualHeaderIdentifier.listPostHeader: const TextHeaderValue('new-post'),
        IndividualHeaderIdentifier.listUnsubscribeHeader: const TextHeaderValue('new-unsub'),
      });

      final result = base.mergeTrackedIndividualHeaders(
        newEmail,
        Properties({
          IndividualHeaderIdentifier.headerCalendarEvent.value,
          IndividualHeaderIdentifier.xPriorityHeader.value,
          IndividualHeaderIdentifier.importanceHeader.value,
          IndividualHeaderIdentifier.priorityHeader.value,
          IndividualHeaderIdentifier.listPostHeader.value,
          IndividualHeaderIdentifier.listUnsubscribeHeader.value,
        }),
      );

      expect(textValue(result[IndividualHeaderIdentifier.headerCalendarEvent]), 'new-cal');
      expect(textValue(result[IndividualHeaderIdentifier.xPriorityHeader]), 'new-x');
      expect(textValue(result[IndividualHeaderIdentifier.importanceHeader]), 'new-imp');
      expect(textValue(result[IndividualHeaderIdentifier.priorityHeader]), 'new-pri');
      expect(textValue(result[IndividualHeaderIdentifier.listPostHeader]), 'new-post');
      expect(textValue(result[IndividualHeaderIdentifier.listUnsubscribeHeader]), 'new-unsub');
    });

    test('non-tracked headers from base are preserved regardless of updatedProperties', () {
      final base = makeEmail({
        IndividualHeaderIdentifier.headerMdn: const TextHeaderValue('mdn@example.com'),
        IndividualHeaderIdentifier.xPriorityHeader: const TextHeaderValue('1'),
      });
      final newEmail = makeEmail({
        IndividualHeaderIdentifier.xPriorityHeader: const TextHeaderValue('3'),
      });

      final result = base.mergeTrackedIndividualHeaders(
        newEmail,
        Properties({IndividualHeaderIdentifier.xPriorityHeader.value}),
      );

      expect(textValue(result[IndividualHeaderIdentifier.headerMdn]), 'mdn@example.com');
      expect(textValue(result[IndividualHeaderIdentifier.xPriorityHeader]), '3');
    });

    test('returns empty map when both emails have no headers', () {
      final base = makeEmail({});
      final newEmail = makeEmail({});

      final result = base.mergeTrackedIndividualHeaders(
        newEmail,
        Properties({IndividualHeaderIdentifier.xPriorityHeader.value}),
      );

      expect(result, isEmpty);
    });

    test('does not mutate base individualHeaders', () {
      final base = makeEmail({
        IndividualHeaderIdentifier.xPriorityHeader: const TextHeaderValue('1'),
      });
      final newEmail = makeEmail({});

      base.mergeTrackedIndividualHeaders(
        newEmail,
        Properties({IndividualHeaderIdentifier.xPriorityHeader.value}),
      );

      expect(
        base.individualHeaders.containsKey(IndividualHeaderIdentifier.xPriorityHeader),
        isTrue,
      );
    });
  });
}
