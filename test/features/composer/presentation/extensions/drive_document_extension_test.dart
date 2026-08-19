import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/drive_document_extension.dart';
import 'package:workplace/domain/entity/drive_document.dart';

DriveDocument _doc({String? sharingLink, String? downloadLink}) => DriveDocument(
      id: 'doc-1',
      name: 'file.pdf',
      size: 100,
      mimeType: 'application/pdf',
      sharingLink: sharingLink == null ? null : Uri.parse(sharingLink),
      downloadLink: downloadLink == null ? null : Uri.parse(downloadLink),
    );

void main() {
  group('DriveDocumentExtension::isAttachableAsLink::', () {
    test('Should accept an https sharingLink whether or not https is required', () {
      final doc = _doc(sharingLink: 'https://drive.example.com/report');

      expect(doc.isAttachableAsLink(requireHttps: true), isTrue);
      expect(doc.isAttachableAsLink(requireHttps: false), isTrue);
    });

    test('Should accept an http sharingLink only when https is not required', () {
      final doc = _doc(sharingLink: 'http://drive.example.com/report');

      expect(doc.isAttachableAsLink(requireHttps: false), isTrue);
      expect(doc.isAttachableAsLink(requireHttps: true), isFalse);
    });

    test('Should reject a javascript sharingLink even when https is not required', () {
      final doc = _doc(sharingLink: 'javascript:alert(document.cookie)');

      expect(doc.isAttachableAsLink(requireHttps: false), isFalse);
      expect(doc.isAttachableAsLink(requireHttps: true), isFalse);
    });

    test('Should reject a data sharingLink even when https is not required', () {
      final doc = _doc(sharingLink: 'data:text/html;base64,PHNjcmlwdD4=');

      expect(doc.isAttachableAsLink(requireHttps: false), isFalse);
      expect(doc.isAttachableAsLink(requireHttps: true), isFalse);
    });

    test('Should reject a null sharingLink', () {
      expect(_doc().isAttachableAsLink(requireHttps: false), isFalse);
    });
  });

  group('DriveDocumentExtension::isAttachableAsDownload::', () {
    test('Should accept a non-empty downloadLink of any scheme', () {
      expect(_doc(downloadLink: 'https://drive.example.com/report-dl').isAttachableAsDownload(), isTrue);
      expect(_doc(downloadLink: 'http://drive.example.com/report-dl').isAttachableAsDownload(), isTrue);
    });

    test('Should reject a null or empty downloadLink', () {
      expect(_doc().isAttachableAsDownload(), isFalse);
      expect(_doc(downloadLink: '').isAttachableAsDownload(), isFalse);
    });

    test('Should stay independent of sharingLink, precedence is the caller\'s job', () {
      final doc = _doc(
        sharingLink: 'https://drive.example.com/report',
        downloadLink: 'https://drive.example.com/report-dl',
      );

      expect(doc.isAttachableAsDownload(), isTrue);
    });
  });
}
