import 'dart:convert';

import 'package:drive_attachment/drive_attachment/domain/message/drive_intent_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const intentId = 'abc123';

  String encode(Map<String, dynamic> map) => jsonEncode(map);

  group('parseDriveIntentMessage', () {
    test('ready type returns DriveIntentReadyMessage', () {
      final raw = encode({'type': 'intent-$intentId:ready'});
      expect(
        DriveIntentMessage.parse(intentId, raw),
        isA<DriveIntentReadyMessage>(),
      );
    });

    test('error type returns DriveIntentErrorMessage', () {
      final raw = encode({'type': 'intent-$intentId:error'});
      expect(
        DriveIntentMessage.parse(intentId, raw),
        isA<DriveIntentErrorMessage>(),
      );
    });

    test('cancel type returns DriveIntentCancelMessage', () {
      final raw = encode({'type': 'intent-$intentId:cancel'});
      expect(
        DriveIntentMessage.parse(intentId, raw),
        isA<DriveIntentCancelMessage>(),
      );
    });

    group('done type', () {
      test('returns DriveIntentDoneMessage with parsed documents', () {
        final raw = encode({
          'type': 'intent-$intentId:done',
          'document': [
            {
              'id': 'doc1',
              'name': 'report.pdf',
              'size': 1024,
              'mimeType': 'application/pdf',
              'sharingLink': 'https://sharing.example.com/file',
              'downloadLink': 'https://download.example.com/file',
            },
          ],
        });

        final msg = DriveIntentMessage.parse(intentId, raw);
        expect(msg, isA<DriveIntentDoneMessage>());

        final done = msg as DriveIntentDoneMessage;
        expect(done.documents.length, 1);
        expect(done.documents.first.id, 'doc1');
        expect(done.documents.first.name, 'report.pdf');
        expect(done.documents.first.size, 1024);
        expect(done.documents.first.mimeType, 'application/pdf');
        expect(done.documents.first.sharingLink, Uri.parse('https://sharing.example.com/file'));
        expect(done.documents.first.downloadLink, Uri.parse('https://download.example.com/file'));
      });

      test('returns empty list when document key is absent', () {
        final raw = encode({'type': 'intent-$intentId:done'});
        final msg = DriveIntentMessage.parse(intentId, raw) as DriveIntentDoneMessage;
        expect(msg.documents, isEmpty);
      });

      test('returns empty list when document is null', () {
        final raw = encode({'type': 'intent-$intentId:done', 'document': null});
        final msg = DriveIntentMessage.parse(intentId, raw) as DriveIntentDoneMessage;
        expect(msg.documents, isEmpty);
      });

      test('parses multiple documents', () {
        final raw = encode({
          'type': 'intent-$intentId:done',
          'document': [
            {'id': 'd1', 'name': 'a.pdf', 'size': 100, 'mimeType': 'application/pdf'},
            {'id': 'd2', 'name': 'b.png', 'size': 200, 'mimeType': 'image/png'},
          ],
        });

        final msg = DriveIntentMessage.parse(intentId, raw) as DriveIntentDoneMessage;
        expect(msg.documents.length, 2);
        expect(msg.documents.map((d) => d.id), containsAllInOrder(['d1', 'd2']));
      });
    });

    group('unknown type', () {
      test('unrecognised type string returns DriveIntentUnknownMessage', () {
        final raw = encode({'type': 'some-other-event'});
        final msg = DriveIntentMessage.parse(intentId, raw);
        expect(msg, isA<DriveIntentUnknownMessage>());
        expect((msg as DriveIntentUnknownMessage).type, 'some-other-event');
      });

      test('missing type field defaults to empty string → DriveIntentUnknownMessage', () {
        final raw = encode(<String, dynamic>{});
        final msg = DriveIntentMessage.parse(intentId, raw);
        expect(msg, isA<DriveIntentUnknownMessage>());
        expect((msg as DriveIntentUnknownMessage).type, '');
      });

      test('correct message type for different intentId is treated as unknown', () {
        final raw = encode({'type': 'intent-other-id:ready'});
        final msg = DriveIntentMessage.parse(intentId, raw);
        expect(msg, isA<DriveIntentUnknownMessage>());
      });
    });
  });
}
