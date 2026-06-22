import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/entity/drive_document_extension.dart';

void main() {
  DriveDocument makeDoc({
    String id = '1',
    String name = 'file.pdf',
    int size = 1024,
    String mimeType = 'application/pdf',
    Uri? sharingLink,
    Uri? downloadLink,
  }) =>
      DriveDocument(
        id: id,
        name: name,
        size: size,
        mimeType: mimeType,
        sharingLink: sharingLink,
        downloadLink: downloadLink,
      );

  // Convenience: split folded header back into param tokens.
  List<String> splitParams(String header) =>
      header.split(';\r\n\t').map((s) => s.trim()).toList();

  group('DriveDocumentExtension.linkedFileHeader', () {
    group('URL selection', () {
      test('uses sharingLink when both present', () {
        final doc = makeDoc(
          sharingLink: Uri.parse('https://sharing.example.com/file'),
          downloadLink: Uri.parse('https://download.example.com/file'),
        );
        expect(splitParams(doc.linkedFileHeader!).first,
            'url=https://sharing.example.com/file');
      });

      test('falls back to downloadLink when sharingLink null', () {
        final doc = makeDoc(
          downloadLink: Uri.parse('https://download.example.com/image'),
        );
        expect(splitParams(doc.linkedFileHeader!).first,
            'url=https://download.example.com/image');
      });

      test('returns null when both links null', () {
        final doc = makeDoc();
        expect(doc.linkedFileHeader, isNull);
      });

      test('returns null for non-https URL (http blocked)', () {
        final doc = makeDoc(
          sharingLink: Uri.parse('http://insecure.example.com/file'),
        );
        expect(doc.linkedFileHeader, isNull);
      });

      test('returns null for javascript: scheme', () {
        final doc = makeDoc(
          sharingLink: Uri.parse('javascript:alert(1)'),
        );
        expect(doc.linkedFileHeader, isNull);
      });
    });

    group('RFC 2822 line folding', () {
      test('params separated by CRLF+tab', () {
        final doc = makeDoc(
          sharingLink: Uri.parse('https://example.com/f'),
        );
        final header = doc.linkedFileHeader!;
        expect(header, contains(';\r\n\t'));
      });

      test('produces exactly 4 params', () {
        final doc = makeDoc(
          sharingLink: Uri.parse('https://example.com/f'),
        );
        expect(splitParams(doc.linkedFileHeader!), hasLength(4));
      });

      test('param order: url, filename, type, size', () {
        final doc = makeDoc(
          sharingLink: Uri.parse('https://example.com/f'),
        );
        final params = splitParams(doc.linkedFileHeader!);
        expect(params[0], startsWith('url='));
        expect(params[1], startsWith('filename'));
        expect(params[2], startsWith('type'));
        expect(params[3], startsWith('size='));
      });
    });

    group('ASCII filename — quoted-string', () {
      test('plain ASCII name quoted correctly', () {
        final doc = makeDoc(
          name: 'report.pdf',
          sharingLink: Uri.parse('https://example.com/f'),
        );
        expect(splitParams(doc.linkedFileHeader!)[1], 'filename="report.pdf"');
      });

      test('spaces preserved inside quotes', () {
        final doc = makeDoc(
          name: 'my file name.docx',
          sharingLink: Uri.parse('https://example.com/f'),
        );
        expect(splitParams(doc.linkedFileHeader!)[1], 'filename="my file name.docx"');
      });

      test('double-quote in name is stripped', () {
        final doc = makeDoc(
          name: 'evil"name.pdf',
          sharingLink: Uri.parse('https://example.com/f'),
        );
        expect(splitParams(doc.linkedFileHeader!)[1], 'filename="evilname.pdf"');
      });

      test('semicolon in name is stripped', () {
        final doc = makeDoc(
          name: 'file;injected=x.pdf',
          sharingLink: Uri.parse('https://example.com/f'),
        );
        final param = splitParams(doc.linkedFileHeader!)[1];
        expect(param, 'filename="fileinjected=x.pdf"');
        expect(param, isNot(contains(';')));
      });

      test('backslash in name is escaped to double-backslash', () {
        final doc = makeDoc(
          name: r'path\file.pdf',
          sharingLink: Uri.parse('https://example.com/f'),
        );
        expect(splitParams(doc.linkedFileHeader!)[1], r'filename="path\\file.pdf"');
      });
    });

    group('Control character stripping', () {
      test('newline in name is stripped', () {
        final doc = makeDoc(
          name: 'file\ninjected.pdf',
          sharingLink: Uri.parse('https://example.com/f'),
        );
        final param = splitParams(doc.linkedFileHeader!)[1];
        expect(param, 'filename="fileinjected.pdf"');
        expect(param, isNot(contains('\n')));
      });

      test('carriage-return in name is stripped', () {
        final doc = makeDoc(
          name: 'file\r.pdf',
          sharingLink: Uri.parse('https://example.com/f'),
        );
        final param = splitParams(doc.linkedFileHeader!)[1];
        expect(param, 'filename="file.pdf"');
        expect(param, isNot(contains('\r')));
      });

      test('C0 control char in name is stripped', () {
        final doc = makeDoc(
          name: 'file\x01name.pdf',
          sharingLink: Uri.parse('https://example.com/f'),
        );
        expect(splitParams(doc.linkedFileHeader!)[1], 'filename="filename.pdf"');
      });
    });

    group('RFC 2231 — non-ASCII filename', () {
      test('Vietnamese filename encoded with RFC 2231', () {
        final doc = makeDoc(
          name: 'Báo cáo.pdf',
          sharingLink: Uri.parse('https://example.com/f'),
        );
        final param = splitParams(doc.linkedFileHeader!)[1];
        expect(param, startsWith("filename*=UTF-8''"));
        expect(param, isNot(contains('"')));
        // Spot-check: 'á' → %C3%A1
        expect(param, contains('%C3%A1'));
      });

      test('CJK filename encoded with RFC 2231', () {
        final doc = makeDoc(
          name: '文件.pdf',
          sharingLink: Uri.parse('https://example.com/f'),
        );
        final param = splitParams(doc.linkedFileHeader!)[1];
        expect(param, startsWith("filename*=UTF-8''"));
      });

      test('emoji filename encoded with RFC 2231', () {
        final doc = makeDoc(
          name: 'report🎉.pdf',
          sharingLink: Uri.parse('https://example.com/f'),
        );
        final param = splitParams(doc.linkedFileHeader!)[1];
        expect(param, startsWith("filename*=UTF-8''"));
      });

      test('pure ASCII name still uses quoted-string, not RFC 2231', () {
        final doc = makeDoc(
          name: 'report.pdf',
          sharingLink: Uri.parse('https://example.com/f'),
        );
        final param = splitParams(doc.linkedFileHeader!)[1];
        expect(param, startsWith('filename="'));
        expect(param, isNot(contains("UTF-8''")));
      });
    });

    group('size and mimeType', () {
      test('size=0 included', () {
        final doc = makeDoc(
          size: 0,
          sharingLink: Uri.parse('https://example.com/f'),
        );
        expect(splitParams(doc.linkedFileHeader!)[3], 'size=0');
      });

      test('large size included', () {
        final doc = makeDoc(
          size: 1073741824,
          sharingLink: Uri.parse('https://example.com/f'),
        );
        expect(splitParams(doc.linkedFileHeader!)[3], 'size=1073741824');
      });

      test('semicolon in mimeType is stripped', () {
        final doc = makeDoc(
          mimeType: 'application/pdf;injected=x',
          sharingLink: Uri.parse('https://example.com/f'),
        );
        final param = splitParams(doc.linkedFileHeader!)[2];
        expect(param, isNot(contains(';injected')));
      });

      test('non-ASCII mimeType uses RFC 2231', () {
        final doc = makeDoc(
          mimeType: 'application/pdfé',
          sharingLink: Uri.parse('https://example.com/f'),
        );
        final param = splitParams(doc.linkedFileHeader!)[2];
        expect(param, startsWith("type*=UTF-8''"));
      });
    });
  });
}
