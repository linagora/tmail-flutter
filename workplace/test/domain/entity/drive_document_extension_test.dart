import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/entity/drive_document_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DriveDocumentExtension.linkedFileHeader', () {
    test('uses sharingLink when both links present', () {
      final doc = DriveDocument(
        id: '1',
        name: 'report.pdf',
        size: 1024,
        mimeType: 'application/pdf',
        sharingLink: Uri.parse('https://sharing.example.com/file'),
        downloadLink: Uri.parse('https://download.example.com/file'),
      );

      expect(
        doc.linkedFileHeader,
        'url=https://sharing.example.com/file; filename="report.pdf"; '
            'type="application/pdf"; size=1024',
      );
    });

    test('falls back to downloadLink when sharingLink is null', () {
      final doc = DriveDocument(
        id: '2',
        name: 'image.png',
        size: 2048,
        mimeType: 'image/png',
        downloadLink: Uri.parse('https://download.example.com/image'),
      );

      expect(
        doc.linkedFileHeader,
        'url=https://download.example.com/image; filename="image.png"; '
            'type="image/png"; size=2048',
      );
    });

    test('url is null when both links are null', () {
      const doc = DriveDocument(
        id: '3',
        name: 'doc.txt',
        size: 512,
        mimeType: 'text/plain',
      );

      expect(
        doc.linkedFileHeader,
        'url=null; filename="doc.txt"; type="text/plain"; size=512',
      );
    });

    test('filename with spaces is quoted correctly', () {
      final doc = DriveDocument(
        id: '4',
        name: 'my file name.docx',
        size: 4096,
        mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        sharingLink: Uri.parse('https://sharing.example.com/doc'),
      );

      expect(
        doc.linkedFileHeader,
        contains('filename="my file name.docx"'),
      );
    });

    test('size zero is represented correctly', () {
      const doc = DriveDocument(
        id: '5',
        name: 'empty.bin',
        size: 0,
        mimeType: 'application/octet-stream',
      );

      expect(doc.linkedFileHeader, contains('size=0'));
    });

    test('double-quote in filename is stripped', () {
      const doc = DriveDocument(
        id: '6',
        name: 'evil"name.pdf',
        size: 100,
        mimeType: 'application/pdf',
      );
      expect(doc.linkedFileHeader, contains('filename="evilname.pdf"'));
    });

    test('semicolon in mimeType is stripped', () {
      const doc = DriveDocument(
        id: '7',
        name: 'file.pdf',
        size: 100,
        mimeType: 'application/pdf;injected=x',
      );
      expect(doc.linkedFileHeader, contains('type="application/pdfinjected=x"'));
      expect(doc.linkedFileHeader, isNot(contains(';injected')));
    });

    test('newline in filename is stripped', () {
      const doc = DriveDocument(
        id: '8',
        name: 'file\ninjected.pdf',
        size: 100,
        mimeType: 'application/pdf',
      );
      final header = doc.linkedFileHeader;
      expect(header, isNot(contains('\n')));
      expect(header, contains('filename="fileinjected.pdf"'));
    });
  });
}
