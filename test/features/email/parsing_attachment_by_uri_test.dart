import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:model/email/attachment.dart';
import 'package:tmail_ui_user/features/email/presentation/extensions/attachment_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';

void main() {
  group('parsingAttachmentByUri', () {
    test('should parse a valid URI and return an Attachment object', () {
      final uri = Uri.parse(
        'attachment:blobId?name=testfile.txt&size=1024&type=text/plain',
      );

      final attachment = EmailUtils.parsingAttachmentByUri(uri);

      expect(attachment, isNotNull);
      expect(attachment!.blobId?.value, 'blobId');
      expect(attachment.name, 'testfile.txt');
      expect(attachment.size?.value, 1024);
      expect(attachment.type?.toString(), 'text/plain');
    });

    test('should return null for an invalid URI', () {
      final uri = Uri.parse('https://example.com');

      final attachment = EmailUtils.parsingAttachmentByUri(uri);

      expect(attachment, isNull);
    });

    test('should handle missing optional parameters gracefully', () {
      final uri = Uri.parse('attachment:blobId?name=testfile.txt');

      final attachment = EmailUtils.parsingAttachmentByUri(uri);

      expect(attachment, isNotNull);
      expect(attachment!.blobId?.value, 'blobId');
      expect(attachment.name, 'testfile.txt');
      expect(attachment.size, isNull);
      expect(attachment.type, isNull);
    });

    test('should handle invalid size parameter gracefully', () {
      final uri = Uri.parse(
        'attachment:blobId?name=testfile.txt&size=invalid',
      );

      final attachment = EmailUtils.parsingAttachmentByUri(uri);

      expect(attachment, isNull);
    });

    test('should handle empty type parameter gracefully', () {
      final uri = Uri.parse(
        'attachment:blobId?name=testfile.txt&type=',
      );

      final attachment = EmailUtils.parsingAttachmentByUri(uri);

      expect(attachment, isNotNull);
      expect(attachment!.blobId?.value, 'blobId');
      expect(attachment.name, 'testfile.txt');
      expect(attachment.type, isNull);
    });
  });

  group('attachmentLink round-trip', () {
    for (final name in ['Q&A.pdf', 'a+b.pdf', 'draft#2.pdf']) {
      test('should parse back "$name" with its size and type', () {
        final original = Attachment(
          blobId: Id('blobId'),
          name: name,
          size: UnsignedInt(1024),
          type: MediaType.parse('application/pdf'),
        );

        final parsed = EmailUtils.parsingAttachmentByUri(Uri.parse(original.attachmentLink));

        expect(parsed, isNotNull);
        expect(parsed!.blobId?.value, 'blobId');
        expect(parsed.name, name);
        expect(parsed.size?.value, 1024);
        expect(parsed.type?.mimeType, 'application/pdf');
      });
    }
  });
}
