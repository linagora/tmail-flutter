import 'dart:convert';

import 'package:workplace/domain/message/workplace_intent_message.dart';
import 'package:flutter_test/flutter_test.dart';

WorkplaceIntentDoneMessage _parseDone(
  String intentId,
  List<Map<String, dynamic>> docs,
) {
  final raw = jsonEncode({
    'type': 'intent-$intentId:done',
    'document': docs,
  });
  return WorkplaceIntentMessage.parse(intentId, raw) as WorkplaceIntentDoneMessage;
}

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
        final done = _parseDone(intentId, [
          {
            'id': 'doc1',
            'name': 'report.pdf',
            'size': 1024,
            'mimeType': 'application/pdf',
            'sharingLink': 'https://sharing.example.com/file',
            'downloadLink': 'https://download.example.com/file',
          },
        ]);
        expect(done.documents.length, 1);
        expect(done.documents.first.id, 'doc1');
        expect(done.documents.first.name, 'report.pdf');
        expect(done.documents.first.size, 1024);
        expect(done.documents.first.mimeType, 'application/pdf');
        expect(done.documents.first.sharingLink, Uri.parse('https://sharing.example.com/file'));
        expect(done.documents.first.downloadLink, Uri.parse('https://download.example.com/file'));
      });

      test('returns empty list when document key is absent', () {
        final msg = WorkplaceIntentMessage.parse(intentId, encode({'type': 'intent-$intentId:done'})) as WorkplaceIntentDoneMessage;
        expect(msg.documents, isEmpty);
      });

      test('returns empty list when document is null', () {
        final msg = WorkplaceIntentMessage.parse(intentId, encode({'type': 'intent-$intentId:done', 'document': null})) as WorkplaceIntentDoneMessage;
        expect(msg.documents, isEmpty);
      });

      test('parses multiple documents', () {
        final done = _parseDone(intentId, [
          {'id': 'd1', 'name': 'a.pdf', 'size': 100, 'mimeType': 'application/pdf'},
          {'id': 'd2', 'name': 'b.png', 'size': 200, 'mimeType': 'image/png'},
        ]);
        expect(done.documents.length, 2);
        expect(done.documents.map((d) => d.id), containsAllInOrder(['d1', 'd2']));
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
          final msg = WorkplaceIntentMessage.parse(otherId, raw);
          expect(msg, isA<WorkplaceIntentMessage>());
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
        final done = _parseDone(intentId, [
          {'id': 'd1', 'name': 'file.txt', 'size': 0, 'mimeType': 'text/plain'},
        ]);
        expect(done.documents.first.sharingLink, isNull);
        expect(done.documents.first.downloadLink, isNull);
      });

      test('document entry with size zero is valid', () {
        final done = _parseDone(intentId, [
          {'id': 'd0', 'name': 'empty.bin', 'size': 0, 'mimeType': 'application/octet-stream'},
        ]);
        expect(done.documents.first.size, 0);
      });

      test('document list with many items preserves order', () {
        final docs = List.generate(
          10,
          (i) => {'id': 'doc$i', 'name': 'f$i.pdf', 'size': i * 100, 'mimeType': 'application/pdf'},
        );
        final done = _parseDone(intentId, docs);
        expect(done.documents.length, 10);
        expect(done.documents.map((d) => d.id), List.generate(10, (i) => 'doc$i'));
      });

      test('malformed document entry is skipped, valid ones kept', () {
        final raw = jsonEncode({
          'type': 'intent-$intentId:done',
          'document': [
            {'id': 'good', 'name': 'ok.pdf', 'size': 100, 'mimeType': 'application/pdf'},
            'not-an-object',
            {'id': 'also-good', 'name': 'ok2.pdf', 'size': 200, 'mimeType': 'image/png'},
          ],
        });
        final done = WorkplaceIntentMessage.parse(intentId, raw) as WorkplaceIntentDoneMessage;
        expect(done.documents.length, 2);
        expect(done.documents.map((d) => d.id), containsAllInOrder(['good', 'also-good']));
      });

      test('document with negative size is filtered out', () {
        final done = _parseDone(intentId, [
          {'id': 'bad', 'name': 'bad.pdf', 'size': -1, 'mimeType': 'application/pdf'},
          {'id': 'good', 'name': 'good.pdf', 'size': 100, 'mimeType': 'application/pdf'},
        ]);
        expect(done.documents.length, 1);
        expect(done.documents.first.id, 'good');
      });

      test('document with non-http(s) url scheme is filtered out', () {
        final done = _parseDone(intentId, [
          {'id': 'unsafe', 'name': 'evil.pdf', 'size': 100, 'mimeType': 'application/pdf', 'downloadLink': 'javascript:alert(1)'},
          {'id': 'safe', 'name': 'safe.pdf', 'size': 100, 'mimeType': 'application/pdf', 'downloadLink': 'https://drive.example.com/file'},
        ]);
        expect(done.documents.length, 1);
        expect(done.documents.first.id, 'safe');
      });

      test('document with http url scheme is accepted', () {
        final done = _parseDone(intentId, [
          {'id': 'http-doc', 'name': 'file.pdf', 'size': 100, 'mimeType': 'application/pdf', 'downloadLink': 'http://drive.example.com/file'},
        ]);
        expect(done.documents.length, 1);
      });

      test('document with no url (null links) is accepted', () {
        final done = _parseDone(intentId, [
          {'id': 'no-url', 'name': 'file.pdf', 'size': 100, 'mimeType': 'application/pdf'},
        ]);
        expect(done.documents.length, 1);
      });
    });
  });
}
