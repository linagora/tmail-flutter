import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
import 'package:model/email/attachment.dart';

void main() {
  final attachmentA = Attachment(
    type: MediaType.parse('application/pdf')
  );

  final attachmentB = Attachment(
    name: 'attachmentB.pdf',
    type: MediaType.parse('application/octet-stream')
  );

  final attachmentC = Attachment(
    name: 'attachmentC.docx',
    type: MediaType.parse('application/octet-stream')
  );

  final attachmentD = Attachment(
    name: 'attachmentD.png',
    type: MediaType.parse('image/png')
  );

  final attachmentE = Attachment(
    name: 'attachmentE.pdf',
    type: MediaType.parse('text/html')
  );

  group('isDisplayedPDFIcon method test', () {
    test(
      'GIVE attachmentA has mimeType = `application/pdf`\n'
      'WHEN perform call `attachmentA.isDisplayedPDFIcon()`\n'
      'SHOULD return true',
    () {
      bool result = attachmentA.type!.isPDFFile(fileName: null);

      expect(result, isTrue);
    });

    test(
      'GIVE attachmentB has mimeType = `application/octet-stream`\n'
      'AND name = `attachmentB.pdf`\n'
      'WHEN perform call `attachmentB.isDisplayedPDFIcon()`\n'
      'SHOULD return true',
    () {
      bool result = attachmentB.type!.isPDFFile(fileName: 'attachmentB.pdf');

      expect(result, isTrue);
    });

    test(
      'GIVE attachmentC has mimeType = `application/octet-stream`\n'
      'AND name = `attachmentC.docx`\n'
      'WHEN perform call `attachmentC.isDisplayedPDFIcon()`\n'
      'SHOULD return false',
    () {
      bool result = attachmentC.type!.isPDFFile(fileName: 'attachmentC.docx');

      expect(result, isFalse);
    });

    test(
      'GIVE attachmentD has mimeType = `image/png`\n'
      'AND name = `attachmentD.png`\n'
      'WHEN perform call `attachmentD.isDisplayedPDFIcon()`\n'
      'SHOULD return false',
    () {
      bool result = attachmentD.type!.isPDFFile(fileName: 'attachmentD.png');

      expect(result, isFalse);
    });

    test(
      'GIVE attachmentE has mimeType = `text/html`\n'
      'AND name = `attachmentE.pdf`\n'
      'WHEN perform call `attachmentE.isDisplayedPDFIcon()`\n'
      'SHOULD return false',
    () {
      bool result = attachmentE.type!.isPDFFile(fileName: 'attachmentE.pdf');

      expect(result, isFalse);
    });
  });
}