import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:model/email/attachment.dart';

void main() {
  final accountId = AccountId(Id('1'));
  const baseDownloadUrl = 'http://localhost/download/{accountId}/{blobId}/{name}?name={name}&type={type}';

  group('attachment test:', () {
    group('getDownloadUrl:', () {
      test(
        'should return download url with blobId, name and type',
      () {
        // arrange
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
          name: 'some-name',
          type: MediaType.parse('application/octet-stream'),
        );
        
        // act
        final result = attachment.getDownloadUrl(baseDownloadUrl, accountId);
        
        // assert
        expect(result, 'http://localhost/download/1/some-blob-id/some-name?name=some-name&type=application%2Foctet-stream');
      });

      test(
        'should return download url with blobId, name and type '
        'when attachment name contains question mark character',
      () {
        // arrange
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
          name: 'some-name?',
          type: MediaType.parse('application/octet-stream'),
        );
        
        // act
        final result = attachment.getDownloadUrl(baseDownloadUrl, accountId);
        
        // assert
        expect(result, 'http://localhost/download/1/some-blob-id/some-name%3F?name=some-name%3F&type=application%2Foctet-stream');
      });

      test(
        'should return download url with blobId, name and type '
        'when attachment name is Vietnamese',
      () {
        // arrange
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
          name: 'tiêu đề attachment',
          type: MediaType.parse('application/octet-stream'),
        );
        
        // act
        final result = attachment.getDownloadUrl(baseDownloadUrl, accountId);
        
        // assert
        expect(result, 'http://localhost/download/1/some-blob-id/ti%C3%AAu%20%C4%91%E1%BB%81%20attachment?name=ti%C3%AAu%20%C4%91%E1%BB%81%20attachment&type=application%2Foctet-stream');
      });
    });

    group('generateFileName:', () {
      String join(List<Object> parts) => parts
          .map((part) => part is int ? String.fromCharCode(part) : part as String)
          .join();

      for (final (parts, expected) in <(List<Object>, String)>[
        (['invoice', 0x202E, 'fdp.exe'], 'invoicefdp.exe'),
        (['rep', 0x2066, 'ort', 0x200F, 0x0007, '.pdf'], 'report.pdf'),
        (['a', 0x0085, 'b', 0x2028, 'c.pdf'], 'abc.pdf'),
        ([0x202E, 'a?b.exe'], 'a_b.exe'),
        ([0x202E, 0x0007, 0x2066], 'unknown-attachment'),
      ]) {
        final name = join(parts);

        test('should sanitize ${name.runes} to $expected', () {
          final attachment = Attachment(blobId: Id('some-blob-id'), name: name);

          expect(attachment.generateFileName(), expected);
        });
      }

      test(
        'should return name when name is not empty',
      () {
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
          name: 'document.pdf',
          type: MediaType.parse('application/pdf'),
        );

        expect(attachment.generateFileName(), 'document.pdf');
      });

      test(
        'should return name is trimmed when name has leading/trailing spaces',
      () {
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
          name: '  document.pdf  ',
          type: MediaType.parse('application/pdf'),
        );

        expect(attachment.generateFileName(), 'document.pdf');
      });

      test(
        'should return blobId with extension when name is null',
      () {
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
          type: MediaType.parse('image/png'),
        );

        expect(attachment.generateFileName(), 'some-blob-id.png');
      });

      test(
        'should return blobId with extension when name is empty',
      () {
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
          name: '',
          type: MediaType.parse('image/png'),
        );

        expect(attachment.generateFileName(), 'some-blob-id.png');
      });

      test(
        'should return blobId with extension when name is only whitespace',
      () {
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
          name: '   ',
          type: MediaType.parse('image/jpeg'),
        );

        expect(attachment.generateFileName(), 'some-blob-id.jpeg');
      });

      test(
        'should return blobId without extension when name is null and type is null',
      () {
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
        );

        expect(attachment.generateFileName(), 'some-blob-id');
      });

      test(
        'should return default name when both name and blobId are null',
      () {
        final attachment = Attachment(
          type: MediaType.parse('image/png'),
        );

        expect(attachment.generateFileName(), 'unknown-attachment');
      });

      test(
        'should sanitize name with question mark character',
      () {
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
          name: 'doc?.pdf',
          type: MediaType.parse('application/pdf'),
        );

        expect(attachment.generateFileName(), 'doc_.pdf');
      });

      test(
        'should sanitize name with forward slash character',
      () {
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
          name: 'folder/document.pdf',
          type: MediaType.parse('application/pdf'),
        );

        expect(attachment.generateFileName(), 'folder_document.pdf');
      });

      test(
        'should return default name when name consists entirely of illegal characters',
      () {
        final attachment = Attachment(
          blobId: Id('some-blob-id'),
          name: '???',
          type: MediaType.parse('application/pdf'),
        );

        expect(attachment.generateFileName(), 'unknown-attachment');
      });

      group('when the name is over 255 UTF-8 bytes:', () {
        int byteLength(String value) => utf8.encode(value).length;

        test('should shorten the base name and keep the extension', () {
          final attachment = Attachment(name: 'invoice${'x' * 250}.pdf');

          final result = attachment.generateFileName();

          expect(result, 'invoice${'x' * 244}.pdf');
          expect(byteLength(result), 255);
        });

        test('should cut a non-Latin name on a code point boundary', () {
          final attachment = Attachment(name: '${'日' * 100}.pdf');

          final result = attachment.generateFileName();

          expect(result, '${'日' * 83}.pdf');
          expect(byteLength(result), 253);
        });

        test('should never split a surrogate pair', () {
          final attachment = Attachment(name: '${'😀' * 70}.pdf');

          final result = attachment.generateFileName();

          expect(result, '${'😀' * 62}.pdf');
          expect(byteLength(result), 252);
        });

        test('should count two bytes for a Cyrillic character', () {
          final attachment = Attachment(name: '${'д' * 200}.pdf');

          final result = attachment.generateFileName();

          expect(result, '${'д' * 125}.pdf');
          expect(byteLength(result), 254);
        });

        test('should count three bytes for a lone surrogate', () {
          final attachment = Attachment(name: '${'\uD83D' * 100}.pdf');

          final result = attachment.generateFileName();

          expect(result, '${'\uD83D' * 83}.pdf');
          expect(byteLength(result), 253);
        });

        test('should return default name when the shortened name has no meaningful content', () {
          final attachment = Attachment(name: '${'_' * 300}a');

          expect(attachment.generateFileName(), 'unknown-attachment');
        });

        test('should cut the whole name when it has no extension', () {
          final attachment = Attachment(name: 'invoice${'x' * 250}');

          expect(attachment.generateFileName(), 'invoice${'x' * 248}');
        });

        test('should cut the whole name when the extension alone is too long', () {
          final attachment = Attachment(name: 'a.${'x' * 300}');

          expect(attachment.generateFileName(), 'a.${'x' * 253}');
        });

        test('should cut a name made only of dots', () {
          final attachment = Attachment(name: '.' * 400);

          expect(attachment.generateFileName(), '.' * 255);
        });

        test('should shorten the blobId and subtype fallback', () {
          final attachment = Attachment(
            blobId: Id('b' * 254),
            type: MediaType.parse('application/pdf'),
          );

          expect(attachment.generateFileName(), '${'b' * 251}.pdf');
        });

        test('should not change a name of exactly 255 bytes', () {
          final name = '${'x' * 251}.pdf';

          expect(Attachment(name: name).generateFileName(), name);
        });

        test('should return the same name on a second pass', () {
          for (final name in [
            'invoice${'x' * 250}.pdf',
            '${'日' * 100}.pdf',
            '${'x' * 254} tail',
            '.' * 400,
          ]) {
            final once = Attachment(name: name).generateFileName();

            expect(Attachment(name: once).generateFileName(), once);
          }
        });
      });
    });
  });
}
