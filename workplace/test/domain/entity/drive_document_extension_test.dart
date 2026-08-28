import 'package:flutter_test/flutter_test.dart';
import 'package:workplace/domain/entity/drive_document.dart';
import 'package:workplace/domain/entity/drive_document_extension.dart';
import 'package:workplace/domain/exceptions/workplace_exceptions.dart';

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

  group('resolveDownloadLinkForStaging', () {
    final httpsLink = Uri.parse('https://drive.example/file');
    final httpLink = Uri.parse('http://drive.example/file');

    test('returns the https link in release mode', () {
      final doc = makeDoc(downloadLink: httpsLink);
      expect(
        doc.resolveDownloadLinkForStaging(isReleaseMode: true),
        httpsLink,
      );
    });

    test('allows http outside release mode', () {
      final doc = makeDoc(downloadLink: httpLink);
      expect(
        doc.resolveDownloadLinkForStaging(isReleaseMode: false),
        httpLink,
      );
    });

    test('throws on http in release mode', () {
      final doc = makeDoc(downloadLink: httpLink);
      expect(
        () => doc.resolveDownloadLinkForStaging(isReleaseMode: true),
        throwsA(isA<DriveDownloadInsecureLinkException>()),
      );
    });

    test('throws when downloadLink is null', () {
      final doc = makeDoc(sharingLink: httpsLink);
      expect(
        () => doc.resolveDownloadLinkForStaging(isReleaseMode: false),
        throwsA(isA<DriveDownloadNullAttachmentException>()),
      );
    });
  });
}
