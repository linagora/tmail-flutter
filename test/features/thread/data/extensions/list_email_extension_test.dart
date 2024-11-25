import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/list_email_extension.dart';

void main() {
  group('ListEmailExtension::sortEmailsById::test', () {
    test('Sort the full list', () {
      final referenceIds = <Id>[
        Id('id1'),
        Id('id2'),
        Id('id3'),
        Id('id4'),
      ];

      final emails = <Email>[
        Email(id: EmailId(Id('id3'))),
        Email(id: EmailId(Id('id1'))),
        Email(id: EmailId(Id('id4'))),
        Email(id: EmailId(Id('id2'))),
      ];

      final result = emails.sortEmailsById(referenceIds);

      expect(
        result.map((e) => e.id!.asString).toList(),
        ['id1', 'id2', 'id3', 'id4'],
      );
    });

    test('Emails list has more elements than referenceIds', () {
      final referenceIds = <Id>[
        Id('id1'),
        Id('id2'),
        Id('id3'),
      ];

      final emails = <Email>[
        Email(id: EmailId(Id('id3'))),
        Email(id: EmailId(Id('id4'))),
        Email(id: EmailId(Id('id1'))),
        Email(id: EmailId(Id('id5'))),
        Email(id: EmailId(Id('id2'))),
      ];

      final result = emails.sortEmailsById(referenceIds);

      expect(
        result.map((e) => e.id!.asString).toList(),
        ['id1', 'id2', 'id3', 'id4', 'id5'],
      );
    });

    test('Emails list has fewer elements than referenceIds', () {
      final referenceIds = <Id>[
        Id('id1'),
        Id('id2'),
        Id('id3'),
        Id('id4'),
      ];

      final emails = <Email>[
        Email(id: EmailId(Id('id3'))),
        Email(id: EmailId(Id('id1'))),
      ];

      final result = emails.sortEmailsById(referenceIds);

      expect(
        result.map((e) => e.id!.asString).toList(),
        ['id1', 'id3'],
      );
    });

    test('Emails list is empty', () {
      final referenceIds = <Id>[
        Id('id1'),
        Id('id2'),
        Id('id3'),
      ];

      final emails = <Email>[];

      final result = emails.sortEmailsById(referenceIds);

      expect(
        result.map((e) => e.id!.asString).toList(),
        [],
      );
    });

    test('ReferenceIds list is empty', () {
      final referenceIds = <Id>[];

      final emails = <Email>[
        Email(id: EmailId(Id('id3'))),
        Email(id: EmailId(Id('id4'))),
        Email(id: EmailId(Id('id1'))),
        Email(id: EmailId(Id('id5'))),
      ];

      final result = emails.sortEmailsById(referenceIds);

      expect(
        result.map((e) => e.id!.asString).toList(),
        ['id3', 'id4', 'id1', 'id5'],
      );
    });

    test('Both lists are empty', () {
      final referenceIds = <Id>[];
      final emails = <Email>[];

      final result = emails.sortEmailsById(referenceIds);

      expect(
        result.map((e) => e.id!.asString).toList(),
        [],
      );
    });

    test('Emails have ids that do not match referenceIds', () {
      final referenceIds = <Id>[
        Id('id1'),
        Id('id2'),
      ];

      final emails = <Email>[
        Email(id: EmailId(Id('id3'))),
        Email(id: EmailId(Id('id4'))),
        Email(id: EmailId(Id('id5'))),
      ];

      final result = emails.sortEmailsById(referenceIds);

      expect(
        result.map((e) => e.id!.asString).toList(),
        ['id3', 'id4', 'id5'],
      );
    });

    test('should keep emails with null IDs in their original order at the end', () {
      // Arrange
      final referenceIds = [
        Id('id2'),
        Id('id1'),
      ];

      final emails = [
        Email(id: EmailId(Id('id1'))),
        Email(id: null),
        Email(id: EmailId(Id('id2'))),
      ];

      // Act
      final sortedEmails = emails.sortEmailsById(referenceIds);

      // Assert
      expect(
        sortedEmails.map((e) => e.id?.asString).toList(),
        ['id2', 'id1', null],
      );
    });
  });
}
