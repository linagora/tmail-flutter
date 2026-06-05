import 'dart:convert';

import 'package:workplace/domain/message/workplace_intent_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const intentId = 'abc123';

  String encode(Map<String, dynamic> map) => jsonEncode(map);

  group('parseWorkplaceIntentMessage', () {
    test('ready type returns WorkplaceIntentReadyMessage', () {
      final raw = encode({'type': 'intent-$intentId:ready'});
      expect(
        WorkplaceIntentMessage.parse(intentId, raw),
        isA<WorkplaceIntentReadyMessage>(),
      );
    });

    test('error type returns WorkplaceIntentErrorMessage', () {
      final raw = encode({'type': 'intent-$intentId:error'});
      expect(
        WorkplaceIntentMessage.parse(intentId, raw),
        isA<WorkplaceIntentErrorMessage>(),
      );
    });

    test('cancel type returns WorkplaceIntentCancelMessage', () {
      final raw = encode({'type': 'intent-$intentId:cancel'});
      expect(
        WorkplaceIntentMessage.parse(intentId, raw),
        isA<WorkplaceIntentCancelMessage>(),
      );
    });

    group('done type', () {
      test('returns WorkplaceIntentDoneMessage with parsed documents', () {
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

        final msg = WorkplaceIntentMessage.parse(intentId, raw);
        expect(msg, isA<WorkplaceIntentDoneMessage>());

        final done = msg as WorkplaceIntentDoneMessage;
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
        final msg = WorkplaceIntentMessage.parse(intentId, raw) as WorkplaceIntentDoneMessage;
        expect(msg.documents, isEmpty);
      });

      test('returns empty list when document is null', () {
        final raw = encode({'type': 'intent-$intentId:done', 'document': null});
        final msg = WorkplaceIntentMessage.parse(intentId, raw) as WorkplaceIntentDoneMessage;
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

        final msg = WorkplaceIntentMessage.parse(intentId, raw) as WorkplaceIntentDoneMessage;
        expect(msg.documents.length, 2);
        expect(msg.documents.map((d) => d.id), containsAllInOrder(['d1', 'd2']));
      });
    });

    group('unknown type', () {
      test('unrecognised type string returns WorkplaceIntentUnknownMessage', () {
        final raw = encode({'type': 'some-other-event'});
        final msg = WorkplaceIntentMessage.parse(intentId, raw);
        expect(msg, isA<WorkplaceIntentUnknownMessage>());
        expect((msg as WorkplaceIntentUnknownMessage).type, 'some-other-event');
      });

      test('missing type field defaults to empty string → WorkplaceIntentUnknownMessage', () {
        final raw = encode(<String, dynamic>{});
        final msg = WorkplaceIntentMessage.parse(intentId, raw);
        expect(msg, isA<WorkplaceIntentUnknownMessage>());
        expect((msg as WorkplaceIntentUnknownMessage).type, '');
      });

      test('correct message type for different intentId is treated as unknown', () {
        final raw = encode({'type': 'intent-other-id:ready'});
        final msg = WorkplaceIntentMessage.parse(intentId, raw);
        expect(msg, isA<WorkplaceIntentUnknownMessage>());
      });

      // Multiple colons in type — only exact suffix match counts
      test('type with multiple colons is unknown', () {
        final raw = encode({'type': 'intent-$intentId:ready:extra'});
        expect(WorkplaceIntentMessage.parse(intentId, raw), isA<WorkplaceIntentUnknownMessage>());
      });

      // Multiple "intent-" prefixes
      test('type prefixed twice is unknown', () {
        final raw = encode({'type': 'intent-intent-$intentId:ready'});
        expect(WorkplaceIntentMessage.parse(intentId, raw), isA<WorkplaceIntentUnknownMessage>());
      });

      // intentId repeated in type
      test('type with intentId repeated is unknown', () {
        final raw = encode({'type': 'intent-$intentId$intentId:ready'});
        expect(WorkplaceIntentMessage.parse(intentId, raw), isA<WorkplaceIntentUnknownMessage>());
      });

      // Suffix of intentId matches another intentId
      test('type matching suffix of intentId is unknown', () {
        // intentId = 'abc123'; 'bc123' is a suffix — must not match
        final raw = encode({'type': 'intent-bc123:ready'});
        expect(WorkplaceIntentMessage.parse(intentId, raw), isA<WorkplaceIntentUnknownMessage>());
      });

      // Upper-cased known action is unknown (case-sensitive)
      test('type with uppercase action is unknown', () {
        final raw = encode({'type': 'intent-$intentId:READY'});
        expect(WorkplaceIntentMessage.parse(intentId, raw), isA<WorkplaceIntentUnknownMessage>());
      });

      // Empty intentId passed to parse — only matches if message also has empty segment
      test('empty intentId only matches type with empty segment', () {
        final raw = encode({'type': 'intent-:ready'});
        expect(WorkplaceIntentMessage.parse('', raw), isA<WorkplaceIntentReadyMessage>());
        expect(WorkplaceIntentMessage.parse(intentId, raw), isA<WorkplaceIntentUnknownMessage>());
      });

      // type value is not a string — impl uses `as String?` hard cast → throws TypeError
      test('non-string type field throws TypeError', () {
        final raw = encode({'type': 42});
        expect(
          () => WorkplaceIntentMessage.parse(intentId, raw),
          throwsA(isA<TypeError>()),
        );
      });

      // Whitespace around known type
      test('type with leading whitespace is unknown', () {
        final raw = encode({'type': ' intent-$intentId:ready'});
        expect(WorkplaceIntentMessage.parse(intentId, raw), isA<WorkplaceIntentUnknownMessage>());
      });

      test('type with trailing whitespace is unknown', () {
        final raw = encode({'type': 'intent-$intentId:ready '});
        expect(WorkplaceIntentMessage.parse(intentId, raw), isA<WorkplaceIntentUnknownMessage>());
      });
    });

    group('all known actions for arbitrary intentId', () {
      const otherId = 'xyz-999';

      for (final entry in {
        'ready': WorkplaceIntentReadyMessage,
        'error': WorkplaceIntentErrorMessage,
        'cancel': WorkplaceIntentCancelMessage,
      }.entries) {
        test('${entry.key} action resolves correctly for intentId=$otherId', () {
          final raw = encode({'type': 'intent-$otherId:${entry.key}'});
          expect(WorkplaceIntentMessage.parse(otherId, raw), isA<WorkplaceIntentMessage>());
          final msg = WorkplaceIntentMessage.parse(otherId, raw);
          expect(msg.runtimeType, entry.value);
        });
      }

      test('done action resolves correctly for intentId=$otherId', () {
        final raw = encode({'type': 'intent-$otherId:done', 'document': []});
        final msg = WorkplaceIntentMessage.parse(otherId, raw);
        expect(msg, isA<WorkplaceIntentDoneMessage>());
        expect((msg as WorkplaceIntentDoneMessage).documents, isEmpty);
      });
    });

    group('done — document field edge cases', () {
      test('document entry with only required fields parses without error', () {
        final raw = encode({
          'type': 'intent-$intentId:done',
          'document': [
            {'id': 'd1', 'name': 'file.txt', 'size': 0, 'mimeType': 'text/plain'},
          ],
        });
        final msg = WorkplaceIntentMessage.parse(intentId, raw) as WorkplaceIntentDoneMessage;
        expect(msg.documents.first.sharingLink, isNull);
        expect(msg.documents.first.downloadLink, isNull);
      });

      test('document entry with size zero is valid', () {
        final raw = encode({
          'type': 'intent-$intentId:done',
          'document': [
            {'id': 'd0', 'name': 'empty.bin', 'size': 0, 'mimeType': 'application/octet-stream'},
          ],
        });
        final msg = WorkplaceIntentMessage.parse(intentId, raw) as WorkplaceIntentDoneMessage;
        expect(msg.documents.first.size, 0);
      });

      test('document list with many items preserves order', () {
        final docs = List.generate(
          10,
          (i) => {'id': 'doc$i', 'name': 'f$i.pdf', 'size': i * 100, 'mimeType': 'application/pdf'},
        );
        final raw = encode({'type': 'intent-$intentId:done', 'document': docs});
        final msg = WorkplaceIntentMessage.parse(intentId, raw) as WorkplaceIntentDoneMessage;
        expect(msg.documents.length, 10);
        expect(msg.documents.map((d) => d.id), List.generate(10, (i) => 'doc$i'));
      });
    });
  });
}
